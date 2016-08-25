-module(elmer_test).

-ifdef(TEST).

-include_lib("eunit/include/eunit.hrl").

-define(ELINE, 0).
-define(USER_BUILD_DIR, "elm-stuff/build-artifacts/0.17.1/user/project/1.0.0").

on_cwd(Cwd, Fun) ->
    {ok, OldDir} = file:get_cwd(),
    try file:set_cwd(Cwd) of
        ok -> Fun()
    after
        ok = file:set_cwd(OldDir)
    end.

elm_compile(ElmModuleName, Format) ->
    ElmFileName = ElmModuleName ++ ".elm",
    on_cwd("tests", fun () -> elmer_compiler:compile([ElmFileName], Format, []) end).

user_build_filepath(ElmModuleName) ->
    ?USER_BUILD_DIR ++ "/" ++ ElmModuleName ++ ".elmo".

elm_load_module(ElmModuleName) ->
    Compiled = elm_compile(ElmModuleName, binary),
    UserElmoFileName = user_build_filepath(ElmModuleName),
    {ok, Module, CompiledBinary} = proplists:get_value(UserElmoFileName, Compiled, elm_not_compiled),
    {module, Module} = code:load_binary(Module, ElmModuleName, CompiledBinary),
    Module.

runs_test() ->
    elm_load_module("Test"),
    Result2 = ('Elm.Native.Utils':append())([[1,2],[3,4]]),
    ?assertEqual([1,2,3,4], Result2).

-endif. %%  TEST
