%%%-------------------------------------------------------------------
%% @doc pegb_assessment public API
%% @end
%%%-------------------------------------------------------------------

-module(pegb_assessment_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/api/v1/auth", pegb_assessment_web_auth, []},
			{"/api/v1/application/documents", pegb_assessment_web_documents, []},
			{"/api/v1/application/submit", pegb_assessment_web_submit, []}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8088}], #{
		env => #{dispatch => Dispatch},
		middlewares => [cowboy_router, jwt_check, cowboy_handler]
	}),
	pegb_assessment_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).

%% internal functions
