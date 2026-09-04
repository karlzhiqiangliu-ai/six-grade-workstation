//======== WorkBuddy适配包装，加到文件末尾 ========
// WorkBuddy把webhook原始请求放入变量 $request
exports.handler = async function(event) {
  const req = {
    method: event.http.method,
    body: event.http.body
  };
  //模拟res对象
  const res = {
    _status:200,
    _headers:{},
    _body:null,
    setHeader(k,v){this._headers[k]=v;},
    status(s){this._status=s;return this;},
    end(){return;},
    json(obj){this._body=obj;}
  };
  await module.exports(req,res);
  return {
    statusCode: res._status,
    headers: res._headers,
    body: res._body
  };
};
