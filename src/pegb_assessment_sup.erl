%%%-------------------------------------------------------------------
%% @doc pegb_assessment top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pegb_assessment_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).
-define(STOP_TIMEOUT,60000).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [
      #{
        id=>pegb_assessment_ets,
        start=>{pegb_assessment_ets,start_link,[]},
        restart=>permanent,
        shutdown=>?STOP_TIMEOUT,
        type=>worker,
        modules=>[pegb_assessment_ets]
      }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
