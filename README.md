# pegb_assessment
Assessment erlang/OTP

For compiling:
> rebar3 compile

Run without release:
> rebar3 shell


> Run and compile: with docker image of erlang:20, on higher version there was an error (related to erlang:get_stacktrace)

**Done tasks**:
1. Middleware for checking jwt for all paths except for [api/v1/auth]
2. GET api/v1/auth accepts authorization header (format of "Basic base64_encoded[CLIENT_ID:CLIENT_SECRET]") after that those CLIENT_ID and CLIENT_SECRET would be checked for existence in config file, related to result of checking credentials, it would response JWT or 401
3. gen_server which inits ETS (in RAM) table with inserted data, and api for getting all inserted data
4. GET api/v1/application/documents would return data as JSON with given format, using api of fetching data from ets
5. POST api/v1/application/submit checks for body format and returns 202 (not correct format) or 200 ()

**Left tasks**:
1. HTTP client for getting data
2. Common tests
3. Swagger
4. Not so clear code((

**Reasons why, I have not finished all tasks**:
1. There was not enough time and energy))
2. The last coding on erlang was 1 year ago))

If you have any questions, I am ready to answer. 

Best regards!!!
