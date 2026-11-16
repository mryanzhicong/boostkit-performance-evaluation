%% Deterministic Erlang workload driver.
%%
%% Usage:
%%   erl -noshell -pa <ebin> -run perf_bench main <scenario> <scale> <label>
%%
%% Every scenario performs a deterministic amount of work derived from <scale>
%% and prints exactly one line:
%%
%%     RESULT scenario=<name> checksum=<value>
%%
%% The parser in scripts/results/parse_benchmark.py validates that line against
%% the committed expected value, so an accidental workload or interpreter change
%% fails the case instead of silently producing different numbers.
%%
%% The bencherl_* scenarios execute upstream benchmark handlers from
%% softlab-ntua/bencherl (pinned commit 317bdbf348def0b2f9ed32cb6621e21083b7e0ca,
%% fetched and SHA-256 verified by scripts/builders/base.sh).  The handlers only
%% return ok, so their RESULT checksum is the deterministic amount of work
%% derived from the exact argument set passed to the handler (message count /
%% participating process count / mandelbrot iterations), which proves the
%% expected argument set was executed to completion.
-module(perf_bench).

-export([main/1]).

-define(INT_MOD, 1000000007).
-define(SCENARIO_TIMEOUT_MS, 600000).

main([Scenario, ScaleArg, Label]) ->
    Scale = list_to_integer(ScaleArg),
    Checksum = run(Scenario, Scale),
    case is_float(Checksum) of
        true ->
            io:format("RESULT scenario=~s checksum=~.12f~n", [Scenario, Checksum]);
        false ->
            io:format("RESULT scenario=~s checksum=~B~n", [Scenario, Checksum])
    end,
    _ = Label,
    halt(0);
main(_) ->
    io:format(standard_error, "usage: perf_bench main <scenario> <scale> <label>~n", []),
    halt(2).

run(Scenario, Scale) ->
    case base_scenario(Scenario) of
        "bencherl_bang" -> bencherl_bang(Scale);
        "bencherl_big" -> bencherl_big(Scale);
        "bencherl_mbrot" -> bencherl_mbrot(Scale);
        "arith_int" -> arith_int(Scale);
        "arith_float" -> arith_float(Scale);
        "list_ops" -> list_ops(Scale);
        "map_ops" -> map_ops(Scale);
        "binary_ops" -> binary_ops(Scale);
        "ets_ops" -> ets_ops(Scale);
        "pingpong" -> pingpong(Scale);
        Other -> erlang:error({unknown_scenario, Other})
    end.

base_scenario(Scenario) ->
    Suffixes = ["_small", "_large", "_short", "_long"],
    lists:foldl(
        fun(Suffix, Acc) ->
            case lists:suffix(Suffix, Acc) andalso length(Acc) > length(Suffix) of
                true -> lists:sublist(Acc, length(Acc) - length(Suffix));
                false -> Acc
            end
        end,
        Scenario,
        Suffixes
    ).

%% ---------------------------------------------------------------------------
%% bencherl upstream handlers (single node, number_of_cores = 1)
%% ---------------------------------------------------------------------------

bencherl_version(Scale) ->
    case Scale of
        1 -> short;
        2 -> intermediate;
        _ -> long
    end.

bencherl_conf() ->
    [{number_of_cores, 1}].

bencherl_bang(Scale) ->
    Version = bencherl_version(Scale),
    [[S, M] | _] = bang:bench_args(Version, bencherl_conf()),
    ok = bang:run([S, M], [], []),
    S * M.

bencherl_big(Scale) ->
    Version = bencherl_version(Scale),
    [[N] | _] = big:bench_args(Version, bencherl_conf()),
    ok = big:run([N], [], []),
    N.

bencherl_mbrot(Scale) ->
    Version = bencherl_version(Scale),
    [[N, Np] | _] = mbrot:bench_args(Version, bencherl_conf()),
    ok = mbrot:run([N, Np], [], []),
    N * Np * N * N.

%% ---------------------------------------------------------------------------
%% Arithmetic / data structure workloads
%% ---------------------------------------------------------------------------

arith_int(Scale) ->
    arith_int(1, Scale, 0).

arith_int(I, Scale, Acc) when I =< Scale ->
    Next = (Acc + ((I * I) rem 1000003)) rem ?INT_MOD,
    arith_int(I + 1, Scale, Next);
arith_int(_, _, Acc) ->
    Acc.

arith_float(Scale) ->
    arith_float(1, Scale, 0.0).

arith_float(I, Scale, Acc) when I =< Scale ->
    arith_float(I + 1, Scale, Acc + math:sqrt(I) + I / 7.0);
arith_float(_, _, Acc) ->
    Acc.

list_ops(Scale) ->
    Values = lists:seq(1, Scale),
    Doubled = lists:map(fun(V) -> (V * 2) rem 1000003 end, Values),
    Ordered = lists:sort(Doubled),
    lists:sum(Ordered) rem ?INT_MOD.

map_ops(Scale) ->
    Map = map_put(1, Scale, #{}),
    map_sum(1, Scale, Map, 0).

map_put(I, Scale, Map) when I =< Scale ->
    map_put(I + 1, Scale, Map#{I => (I * 7) rem 1000003});
map_put(_, _, Map) ->
    Map.

map_sum(I, Scale, Map, Acc) when I =< Scale ->
    map_sum(I + 1, Scale, Map, (Acc + maps:get(I, Map)) rem ?INT_MOD);
map_sum(_, _, _Map, Acc) ->
    Acc.

binary_ops(Scale) ->
    Bin = build_binary(1, Scale, []),
    sum_binary(Bin, 0).

build_binary(I, Scale, Acc) when I =< Scale ->
    build_binary(I + 1, Scale, [Acc, <<I:64/integer>>]);
build_binary(_, _, Acc) ->
    iolist_to_binary(Acc).

sum_binary(<<>>, Acc) ->
    Acc;
sum_binary(<<Value:64/integer, Rest/binary>>, Acc) ->
    sum_binary(Rest, (Acc + (Value rem 1000003)) rem ?INT_MOD).

ets_ops(Scale) ->
    Table = ets:new(perf_bench, [set, private]),
    ok = ets_fill(Table, 1, Scale),
    Sum = ets_sum(Table, 1, Scale, 0),
    true = ets:delete(Table),
    Sum.

ets_fill(_Table, I, Scale) when I > Scale -> ok;
ets_fill(Table, I, Scale) ->
    true = ets:insert(Table, {I, (I * 11) rem 1000003}),
    ets_fill(Table, I + 1, Scale).

ets_sum(_Table, I, Scale, Acc) when I > Scale -> Acc;
ets_sum(Table, I, Scale, Acc) ->
    [{I, Value}] = ets:lookup(Table, I),
    ets_sum(Table, I + 1, Scale, (Acc + Value) rem ?INT_MOD).

pingpong(Scale) ->
    Parent = self(),
    Echo = spawn_link(fun() -> echo_loop(Parent) end),
    Count = ping_round(Echo, Scale, 0),
    Echo ! stop,
    Count.

echo_loop(Parent) ->
    receive
        {ping, From} ->
            From ! pong,
            echo_loop(Parent);
        stop ->
            ok
    end.

ping_round(_Echo, 0, Acc) ->
    Acc;
ping_round(Echo, N, Acc) ->
    Echo ! {ping, self()},
    receive
        pong -> ping_round(Echo, N - 1, Acc + 1)
    after ?SCENARIO_TIMEOUT_MS ->
        erlang:error(pingpong_timeout)
    end.
