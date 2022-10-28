-module(pegb_assessment_web_documents).

-behaviour(cowboy_handler).

%% API
-export([
  init/2,
  terminate/3
]).


%%=================================================================
%%	Cowboy behaviour
%%=================================================================
init(Req0, Opts) ->
  Method = cowboy_req:method(Req0),
  Req = handle_request(Method, Req0),
  {ok, Req, Opts}.


terminate(_Reason, _Req, _State) ->
  ok.

%%=================================================================
%%	Internal
%%=================================================================
handle_request(<<"GET">>, Req) ->
  Models = pegb_assessment_ets:get_document_module(),
  Return = #{
    <<"activation_max_liveness_attempts">> => 4,
    <<"innovatrics_minimum_liveness_score">> => 0.9,
    <<"liveness_check">> => passive
  },
  Return1 = Return#{<<"models">> => Models},
  cowboy_req:reply(200, #{
    <<"content-type">> => <<"application/json">>
  }, jiffy:encode(Return1), Req);
handle_request(_, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).
