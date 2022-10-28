-module(pegb_assessment_ets).
-behaviour(gen_server).


%% API
-export(
[
  start_link/0,
  get_document_module/0
]).

%% gen_server callbacks
-export([
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  terminate/2,
  code_change/3
]).

start_link() ->
  gen_server:start_link({local,?MODULE},?MODULE,[],[]).


%% ====================================================================
%% Server functions
%% ====================================================================
init([])->
  Table = ets:new(document_module, [set, named_table]),
  ets:insert(Table, {<<"passport">>, <<"Passport">>}),
  ets:insert(Table, {<<"6c5e1ef9-e66b-4714-8683-c48b69661727">>, <<"National ID - 2011-01-01">>}),
  ets:insert(Table, {<<"3b9233df-6f5e-49a9-990d-62efaac1d201">>, <<"Foreigner Permanent Residence">>}),
  ets:insert(Table, {<<"5c52b74a-f3a7-446b-9dc6-8e5370c4f940">>, <<"United  Identity Card">>}),
  ets:insert(Table, {<<"44991a9e-ee01-4830-8d41-7c34e65a65e2">>, <<"National ID - 2008-11-01">>}),
  {ok,Table}.

handle_call(get_document_module,_From,Table) ->
  ReturnedMap = get_all_data_from_ets(start, Table, #{}),
  {reply, ReturnedMap, Table};
handle_call(_Request,_From,State) ->
  {reply, ok, State}.

handle_cast(_,State) ->
  {noreply, State}.


handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%% ====================================================================
%% API
%% ====================================================================
get_document_module()->
  gen_server:call(?MODULE,get_document_module).


get_all_data_from_ets(start, Table, Map) ->
  FirstKey = ets:first(Table),
  get_all_data_from_ets(FirstKey, Table, Map);
get_all_data_from_ets('$end_of_table', _Table, Map) ->
  Map;
get_all_data_from_ets(Key, Table, Map) ->
  [{_, Val}] = ets:lookup(Table, Key),
  Map1 = Map#{Key => Val},
  NextKey = ets:next(Table, Key),
  get_all_data_from_ets(NextKey, Table, Map1).
