local encode_base64
encode_base64 = require("lapis.util.encoding").encode_base64
local RestyGraylog
do
  local _class_0
  local _base_0 = {
    pwd = "",
    uname = "",
    headers_info = "",
    endpoints = {
      ['s_uat'] = {
        ['/search/universal/absolute/terms'] = {
          'field',
          'query',
          'from',
          'to',
          'limit'
        }
      },
      ['s_ua'] = {
        ['/search/universal/absolute'] = {
          'fields',
          'query',
          'from',
          'to',
          'limit'
        }
      },
      ['s_urt'] = {
        ['/search/universal/relative/terms'] = {
          'field',
          'query',
          'range'
        }
      },
      ['s_ut'] = {
        ['/search/universal/relative'] = {
          'fields',
          'query',
          'range'
        }
      }
    }
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "RestyGraylog"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.build_headers = function(self)
    local auth = "Basic " .. encode_base64(self.uname .. ":" .. self.pwd)
    print(auth)
    local headers = {
      ['Authorization'] = auth,
      ['Accept'] = '*/*',
      ['Content-Type'] = 'application/json'
    }
    return headers
  end
  self.auth = function(self, username, password, host, port)
    local errList = { }
    if type(port) == 'nil' then
      table.insert(errList, "port is nil\n")
    end
    if type(host) == 'nil' then
      table.insert(errList, "host is nil\n")
    end
    if type(password) == 'nil' then
      table.insert(errList, "password is nil\n")
    end
    if type(username) == 'table' then
      table.insert(errList, "username is nil\n")
    end
    local num = table.getn(errList)
    if num > 0 then
      return errList
    end
    self.uname = username
    self.pwd = password
    self.host = host
    self.port = port
    self.url = "http://" .. host .. ":" .. port
    self.auth = "Basic " .. encode_base64(self.uname .. ":" .. self.pwd)
    self.headers_info = self:build_headers()
    return self.url
  end
  self.getRequestSimple = function(self, req_url)
    local body, status_code, headers = http.simple({
      url = req_url,
      method = "GET",
      headers = self.headers_info
    })
    return body
  end
  self.postRequest = function(self, req_url, data)
    local http = require("resty.http")
    local httpc = http.new()
    local metadata = {
      method = "PUT",
      body = data,
      headers = self.headers_info
    }
    local res, err = httpc:request_uri(req_url, metadata)
    if not res then
      ngx.say("failed to request: ", err)
      return 
    end
    ngx.status = res.status
    return res.body
  end
  self.checkParam = function(self, s_type, s_param)
    if type(self.url) == "nil" then
      return 'auth info err.'
    end
    local info = self.endpoints[s_type]
    local chk_flg = type(info)
    if chk_flg == "nil" then
      return "Input parameter error,unknow type."
    end
    local key = ''
    for k, v in pairs(info) do
      key = k
    end
    local str = ''
    for k, v in pairs(info[key]) do
      if type(s_param[v]) == 'nil' then
        return info[key][k] .. ":is nil"
      end
      str = str .. s_param[v]
    end
    return "OK", str
  end
  self.call = function(self, s_type, s_param)
    local key = ''
    for k, v in pairs(self.endpoints[s_type]) do
      key = k
    end
    local url_data = ngx.encode_args(s_param)
    local tmp_url = self.url .. key .. "?"
    local req_url = tmp_url .. url_data
    local ret = self:getRequest(req_url)
    return ret
  end
  self.dealStream = function(self, s_type, s_param)
    local ret = ''
    local status, param_list = GMoonSDK:checkParam(s_type, s_param)
    if status == "OK" then
      ret = GMoonSDK:call(s_type, s_param)
    else
      ret = status
    end
    return ret
  end
  self.putRequest = function(self, req_url, data)
    local http = require("resty.http")
    local httpc = http.new()
    local metadata = {
      method = "PUT",
      body = data,
      headers = self.headers_info
    }
    local res, err = httpc:request_uri(req_url, metadata)
    if not res then
      ngx.say("failed to request: ", err)
      return 
    end
    return res.body
  end
  self.updateWidget = function(self, dashboardId, widgetId, jsonBody)
    local errList = { }
    if type(dashboardId) == 'nil' then
      table.insert(errList, "dashboard id is nil\n")
    end
    if type(widgetId) == 'nil' then
      table.insert(errList, "widget id is nil\n")
    end
    if type(jsonBody) == 'nil' then
      table.insert(errList, "json body is nil\n")
    end
    local num = table.getn(errList)
    if num > 0 then
      return errList
    end
    local url = "http://" .. self.host .. ":" .. self.port
    local req_url = url .. '/dashboards/' .. dashboardId .. '/widgets/' .. widgetId
    self.headers_info = {
      ['Authorization'] = self.auth,
      ['Accept'] = '*/*',
      ['Content-Type'] = 'application/json'
    }
    self:putRequest(req_url, jsonBody)
    return 1
  end
  self.getRequest = function(self, req_url)
    local http = require("resty.http")
    local httpc = http.new()
    local metadata = {
      method = "GET",
      headers = self.headers_info
    }
    local res, err = httpc:request_uri(req_url, metadata)
    if not res then
      ngx.say("failed to request: ", err)
      return 
    end
    ngx.status = res.status
    return res.body
  end
  self.getWidgetValue = function(self, dashboardId, widgetId)
    local errList = { }
    if type(dashboardId) == 'nil' then
      table.insert(errList, "dashboard id is nil\n")
    end
    if type(widgetId) == 'nil' then
      table.insert(errList, "widget id is nil\n")
    end
    local num = table.getn(errList)
    if num > 0 then
      return errList
    end
    local url = "http://" .. self.host .. ":" .. self.port
    local req_url = url .. '/dashboards/' .. dashboardId .. '/widgets/' .. widgetId .. '/value'
    self.headers_info = {
      ['Authorization'] = self.auth,
      ['Accept'] = 'application/json'
    }
    local ret = self:getRequest(req_url)
    return ret
  end
  RestyGraylog = _class_0
  return _class_0
end
