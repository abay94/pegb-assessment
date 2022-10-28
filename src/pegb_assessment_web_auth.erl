-module(pegb_assessment_web_auth).

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
  AuthHeader = jwt_check:does_authorization_header_exist(Req0),
  Req = handle_request(Method, AuthHeader, Req0),
  {ok, Req, Opts}.

terminate(_Reason, _Req, _State) ->
  ok.

%%=================================================================
%%	Internal
%%=================================================================
handle_request(<<"GET">>, not_found, Req) ->
  cowboy_req:reply(400, #{}, <<"There is no auth header">>, Req);
handle_request(<<"GET">>, AuthHeader, Req) ->
  case parse_auth_header(AuthHeader) of
    {ClientId, ClientSecret} ->
      Ret = jwt_check:does_exist_client_info(ClientId, ClientSecret),
      if
        Ret == true ->
          Claims = [
            {client_id, ClientId},
            {client_secret, ClientSecret}
          ],
          {ok, Jwt} = jwt:encode(<<"HS256">>, Claims, jwt_check:get_jwt_key()),
          cowboy_req:reply(200, #{}, Jwt, Req);
        true ->
          cowboy_req:reply(400, #{}, <<"ClientId and clientSecret are not approved!">>, Req)
      end;
    error ->
      cowboy_req:reply(400, #{}, <<"Authorization header format is not correct!">>, Req)
  end;
handle_request(_, _, Req) ->
  %% Method not allowed.
  cowboy_req:reply(405, Req).


parse_auth_header(Token1) ->
  Token = binary:replace(Token1, <<"Basic ">>, <<"">>),
  try
    PartsDecoded = binary:split(base64:decode(Token), <<":">>),
    case PartsDecoded of
      [User, Secret |_] -> {User, Secret};
      _ -> error
    end
  catch
    _: _ -> error
  end.