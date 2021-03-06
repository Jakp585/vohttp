---------------
-- ## HTTP Response Object.
--
-- [Github Page](https://github.com/fhirschmann/vohttp)
--
-- @author Fabian Hirschmann <fabian@hirschmann.email>
-- @copyright 2013
-- @license MIT/X11

vohttp.response = {}
vohttp.response.Response = {}
vohttp.response.GenericResponse = {}
vohttp.response.NotFoundResponse = {}
vohttp.response.InternalServerErrorResponse = {}

--- Creates a new empty HTTP Response Object (with default values).
function vohttp.response.Response:new()
    local new = {}
    for k, v in pairs(vohttp.response.Response) do
        new[k] = v
    end

    --- the status code (defaults to 200)
    new.status_code = 200

    --- the status message (defaults to "OK")
    new.status_message = "OK"

    --- the http version (defaults to "1.0" and should not be changed)
    new.version = "1.0"

    -- disconnect after serving this response
    new.disconnect = true

    --- any additional headers such as content-type
    new.headers = {}
    new.headers["Content-Type"] = "text/html"
    new.headers["Connection"] = "close"

    --- the response body (the content)
    new.body = ""

    return new
end

--- Constructs a Response string ready to be served
function vohttp.response.Response:construct()
    local lines = {}
    table.insert(lines, table.concat({"HTTP/"..self.version, self.status_code,
                                      self.status_message}, " "))

    for k, v in pairs(self.headers) do
        if v == "Content-Type" then
            if not v:match("charset") then
                v = v.."; charset=iso-8859-1"
            end
        end
        table.insert(lines, k..": "..v)
    end

    table.insert(lines, "Content-Length: "..self.body:len())

    table.insert(lines, "\r")
    table.insert(lines, self.body)

    return lines
end

--- A shorthand for generating simple responses (i.e., 404)
-- @param status_code the HTTP status code
-- @param status_message the status message for the given status code
-- @param body the body of the response (the content)
function vohttp.response.GenericResponse:new(status_code, status_message, body)
    local response = vohttp.response.Response:new()
    response.status_code = status_code
    response.status_message = status_message
    response.body = body

    return response
end

--- Constructs a 404 (Not Found) Response
function vohttp.response.NotFoundResponse:new()
    return vohttp.response.GenericResponse:new(404, "Not Found",
        "<html><body><h1>Not found</h1>The requested page was not found on this server.</body></html>")
end

--- Constructs a new 500 (Internal Server Error) Response
-- @param msg the error message
function vohttp.response.InternalServerErrorResponse:new(msg)
    return vohttp.response.GenericResponse:new(500, "Internal Server Error",
        "<html><body><h1>Internal Server Error</h1><pre>."..msg.."</pre></body></html>")
end
