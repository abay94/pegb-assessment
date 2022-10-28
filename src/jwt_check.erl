-module(jwt_check).
-behaviour(cowboy_middleware).

-export([
  execute/2,
  does_authorization_header_exist/1,
  get_jwt_key/0,
  does_exist_client_info/2
]).

-define(JWT_KEY, <<"salt">>).

execute(Req, Env) ->
  case get_path(Req) of
    error ->
      cowboy_req:reply(401, Req),
      {stop, Req};
    <<"/api/v1/auth">> ->
      {ok, Req, Env};
    _ ->
      verify_jwt(Req, Env)
  end.

verify_jwt(Req, Env)->
  try
    case does_authorization_header_exist(Req) of
      not_found ->
        cowboy_req:reply(401, Req),
        {stop, Req};
      JwtToken ->
        {ok, Claims} = jwt:decode(JwtToken, ?JWT_KEY),
        does_exist_claims(Req, Env, Claims)
    end
  catch
      _: E ->
        cowboy_req:reply(401, Req),
        {stop, Req}
  end.

does_exist_claims(Req, Env, #{<<"client_id">> := Id, <<"client_secret">> := ClientSecret}) ->
  Ret = does_exist_client_info(Id, ClientSecret),
  if
    Ret == true ->
      {ok, Req, Env};
    true ->
      cowboy_req:reply(401, Req),
      {stop, Req}
  end;
does_exist_claims(Req, _Env, _) ->
  cowboy_req:reply(401, Req),
  {stop, Req}.


does_exist_client_info(ClientId, ClientSecret)->
  case application:get_env(pegb_assessment, approved_clients) of
    {ok, ApprovedClients} ->
      case maps:get(ClientId, ApprovedClients) of
        {badkey, _Key} -> false;
        ClientSecret -> true;
        _ -> false
      end;
    _ -> false
  end.

get_path(#{path := Path}) ->
  Path;
get_path(_) ->
  error.

get_jwt_key() ->
  ?JWT_KEY.


does_authorization_header_exist(#{headers := #{<<"authorization">> := Token}}) ->
  Token;
does_authorization_header_exist(_) ->
  not_found.
