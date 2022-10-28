-module(pegb_assessment_web_submit).

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
handle_request(<<"POST">>, Req0) ->
  {ok, Body, Req} = cowboy_req:read_body(Req0),
  IsCorrectBody = validate_body(Body),
  if
    IsCorrectBody == false ->
      cowboy_req:reply(202, #{}, <<"The format of body is not correct">>, Req);
    true ->
      cowboy_req:reply(200, #{
        <<"content-type">> => <<"application/json">>
      }, "Good", Req)
  end;
handle_request(_, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).

validate_body(Body1) ->
  { Body } = jiffy:decode(Body1),
  case Body of
    [{<<"image">>, { [{<<"data">>, _ }|_]}}|_] -> true;
    _ -> false
  end.