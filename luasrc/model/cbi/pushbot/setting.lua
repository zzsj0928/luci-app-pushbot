
local nt = require "luci.sys".net
local fs=require"nixio.fs"
local e=luci.model.uci.cursor()
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local ifaces = sys.net:devices()

m=Map("pushbot",translate("PushBot"),
translate("「全能推送」，英文名「PushBot」，是一款从服务器推送报警信息和日志到各平台的工具�?br>支持钉钉推送，企业微信推送，PushPlus推送�?br>本插件由tty228/luci-app-serverchan创建，然后七年修改为全能推送自用�?br /><br />如果你在使用中遇到问题，请到这里提交�?)
.. [[<a href="https://github.com/zzsj0928/luci-app-pushbot" target="_blank">]]
.. translate("github 项目地址")
.. [[</a>]]
)

m:section(SimpleSection).template  = "pushbot/pushbot_status"

s=m:section(NamedSection,"pushbot","pushbot",translate(""))
s:tab("basic", translate("基本设置"))
s:tab("content", translate("推送内�?))
s:tab("crontab", translate("定时推�?))
s:tab("disturb", translate("免打�?))
s:tab("showdoc", translate("ShowDoc"))
o = s:taboption("showdoc", Flag, "enable_showdoc", translate("启用 ShowDoc 推�?))
o = s:taboption("showdoc", Value, "showdoc_api_key", translate("API Key"))
o = s:taboption("showdoc", Value, "showdoc_api_token", translate("API Token"))
o = s:taboption("showdoc", Value, "showdoc_item_id", translate("文档 ID"))
s.addremove = false
s.anonymous = true

--基本设置
a=s:taboption("basic", Flag,"pushbot_enable",translate("启用"))
a.default=0
a.rmempty = true

--精简模式
a = s:taboption("basic", MultiValue, "lite_enable", translate("精简模式"))
a:value("device", translate("精简当前设备列表"))
a:value("nowtime", translate("精简当前时间"))
a:value("content", translate("只推送标�?))
a.widget = "checkbox"
a.default = nil
a.optional = true

--推送模�?
a=s:taboption("basic", ListValue,"jsonpath",translate("推送模�?))
a.default="/usr/bin/pushbot/api/dingding.json"
a.rmempty = true
a:value("/usr/bin/pushbot/api/dingding.json",translate("钉钉"))
a:value("/usr/bin/pushbot/api/ent_wechat.json",translate("企业微信"))
a:value("/usr/bin/pushbot/api/feishu.json",translate("飞书"))
a:value("/usr/bin/pushbot/api/bark.json",translate("Bark"))
a:value("/usr/bin/pushbot/api/pushplus.json",translate("PushPlus"))
a:value("/usr/bin/pushbot/api/pushdeer.json",translate("PushDeer"))
a:value("/usr/bin/pushbot/api/diy.json",translate("自定义推�?))

a=s:taboption("basic", Value,"dd_webhook",translate('Webhook'), translate("钉钉机器�?Webhook").."，只输入access_token=后面的即�?br>调用代码获取<a href='https://developers.dingtalk.com/document/robots/custom-robot-access' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/dingding.json")

a=s:taboption("basic", Value, "we_webhook", translate("Webhook"),translate("企业微信机器�?Webhook").."，只输入key=后面的即�?br>调用代码获取<a href='https://work.weixin.qq.com/api/doc/90000/90136/91770' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/ent_wechat.json")

a=s:taboption("basic", Value,"pp_token",translate('PushPlus Token'), translate("PushPlus Token").."<br>调用代码获取<a href='http://pushplus.plus/doc/' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushplus.json")

a=s:taboption("basic", ListValue,"pp_channel",translate('PushPlus Channel'))
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushplus.json")
a:value("wechat",translate("wechat：PushPlus微信公众�?))
a:value("cp",translate("cp：企业微信应�?))
a:value("webhook",translate("webhook：第三方webhook"))
a:value("sms",translate("sms：短�?))
a:value("mail",translate("mail：邮�?))
a.description = translate("第三方webhook：企业微信、钉钉、飞书、server�?br>sms短信/mail邮箱：PushPlus暂未开�?br>具体channel设定参见�?a href='http://pushplus.plus/doc/extend/webhook.html' target='_blank'>点击这里</a>")

a=s:taboption("basic", Value,"pp_webhook",translate('PushPlus Custom Webhook'), translate("PushPlus 自定义Webhook").."<br>第三方webhook或企业微信调�?br>具体自定义Webhook设定参见�?a href='http://pushplus.plus/doc/extend/webhook.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pp_channel","cp")
a:depends("pp_channel","webhook")

a=s:taboption("basic", Flag,"pp_topic_enable",translate("PushPlus 一对多推�?))
a.default=0
a.rmempty = true
a:depends("pp_channel","wechat")

a=s:taboption("basic", Value,"pp_topic",translate('PushPlus Topic'), translate("PushPlus 群组编码").."<br>一对多推送时指定的群组编�?br>具体群组编码Topic设定参见�?a href='http://www.pushplus.plus/push2.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pp_topic_enable","1")

a=s:taboption("basic", Value,"pushdeer_key",translate('PushDeer Key'), translate("PushDeer Key").."<br>调用代码获取<a href='http://www.pushdeer.com/' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushdeer.json")

a=s:taboption("basic", Flag,"pushdeer_srv_enable",translate("自建 PushDeer 服务�?))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/pushdeer.json")

a=s:taboption("basic", Value,"pushdeer_srv",translate('PushDeer Server'), translate("PushDeer 自建服务器地址").."<br>如https://your.domain:port<br>具体自建服务器设定参见：<a href='http://www.pushdeer.com/selfhosted.html' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("pushdeer_srv_enable","1")

a=s:taboption("basic", Value,"fs_webhook",translate('WebHook'), translate("飞书 WebHook").."<br>调用代码获取<a href='https://www.feishu.cn/hc/zh-CN/articles/360024984973' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/feishu.json")

a=s:taboption("basic", Value,"bark_token",translate('Bark Token'), translate("Bark Token").."<br>调用代码获取<a href='https://github.com/Finb/Bark' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Flag,"bark_srv_enable",translate("自建 Bark 服务�?))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Value,"bark_srv",translate('Bark Server'), translate("Bark 自建服务器地址").."<br>如https://your.domain:port<br>具体自建服务器设定参见：<a href='https://github.com/Finb/Bark' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a:depends("bark_srv_enable","1")

a=s:taboption("basic", Value,"bark_sound",translate('Bark Sound'), translate("Bark 通知声音").."<br>如silence.caf<br>具体设定参见�?a href='https://github.com/Finb/Bark/tree/master/Sounds' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a.default = "silence.caf"
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Flag,"bark_icon_enable",translate(" Bark 通知图标"))
a.default=0
a.rmempty = true
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", Value,"bark_icon",translate('Bark Icon'), translate("Bark 通知图标").."(�?iOS15 或以上支�?<br>如http://day.app/assets/images/avatar.jpg<br>具体设定参见�?a href='https://github.com/Finb/Bark#%E5%85%B6%E4%BB%96%E5%8F%82%E6%95%B0' target='_blank'>点击这里</a><br><br>")
a.rmempty = true
a.default = "http://day.app/assets/images/avatar.jpg"
a:depends("bark_icon_enable","1")

a=s:taboption("basic", Value,"bark_level",translate('Bark Level'), translate("Bark 时效性通知").."<br>可选参数值：<br/>active：不设置时的默认值，系统会立即亮屏显示通知�?br/>timeSensitive：时效性通知，可在专注状态下显示通知�?br/>passive：仅将通知添加到通知列表，不会亮屏提醒�?)
a.rmempty = true
a.default = "active"
a:depends("jsonpath","/usr/bin/pushbot/api/bark.json")

a=s:taboption("basic", TextValue, "diy_json", translate("自定义推�?))
a.optional = false
a.rows = 28
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/diy.json")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/diy.json", value:gsub("\r\n", "\n"))
end
a:depends("jsonpath","/usr/bin/pushbot/api/diy.json")

a=s:taboption("basic", Button,"__add",translate("发送测�?))
a.inputtitle=translate("发�?)
a.inputstyle = "apply"
function a.write(self, section)
	luci.sys.call("cbi.apply")
	luci.sys.call("/usr/bin/pushbot/pushbot test &")
end

a=s:taboption("basic", Value,"device_name",translate('本设备名�?))
a.rmempty = true
a.description = translate("在推送信息标题中会标识本设备名称，用于区分推送信息的来源设备")

a=s:taboption("basic", Value,"sleeptime",translate('检测时间间�?))
a.rmempty = true
a.optional = false
a.default = "60"
a.datatype = "and(uinteger,min(10))"
a.description = translate("越短的时间时间响应越及时，但会占用更多的系统资源")

a=s:taboption("basic", ListValue,"oui_data",translate("MAC设备信息数据�?))
a.rmempty = true
a.default=""
a:value("",translate("关闭"))
a:value("1",translate("简化版"))
a:value("2",translate("完整�?))
a:value("3",translate("网络查询"))
a.description = translate("需下载 4.36m 原始数据，处理后完整版约 1.2M，简化版�?250kb <br/>若无梯子，请勿使用网络查�?)

a=s:taboption("basic", Flag,"oui_dir",translate("下载到内�?))
a.rmempty = true
a:depends("oui_data","1")
a:depends("oui_data","2")
a.description = translate("懒得做自动更新了，下载到内存中，重启会重新下�?<br/>若无梯子，还是下到机身吧")

a=s:taboption("basic", Flag,"reset_regularly",translate("每天零点重置流量数据"))
a.rmempty = true

a=s:taboption("basic", Flag,"debuglevel",translate("开启日�?))
a.rmempty = true

a= s:taboption("basic", DynamicList, "device_aliases", translate("设备别名"))
a.rmempty = true
a.description = translate("<br/> 请输入设�?MAC 和设备别名，用�?”隔开，如�?br/> XX:XX:XX:XX:XX:XX-我的手机")

--设备状�?
a=s:taboption("content", ListValue,"pushbot_ipv4",translate("IPv4 变更通知"))
a.rmempty = true
a.default=""
a:value("",translate("关闭"))
a:value("1",translate("通过接口获取"))
a:value("2",translate("通过URL获取"))

a = s:taboption("content", ListValue, "ipv4_interface", translate("接口名称"))
a.rmempty = true
a:depends({pushbot_ipv4="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>一般选择 wan 接口，多拨环境请自行选择")

a=s:taboption("content", TextValue, "ipv4_list", translate("IPv4 API列表"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ipv4.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ipv4.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>会因服务器稳定性、连接频繁等原因导致获取失败<br/>如接口可以正常获�?IP，不推荐使用<br/>从以上列表中随机地址访问")
a:depends({pushbot_ipv4="2"})

a=s:taboption("content", ListValue,"pushbot_ipv6",translate("IPv6 变更通知"))
a.rmempty = true
a.default="disable"
a:value("0",translate("关闭"))
a:value("1",translate("通过接口获取"))
a:value("2",translate("通过URL获取"))

a = s:taboption("content", ListValue, "ipv6_interface", translate("接口名称"))
a.rmempty = true
a:depends({pushbot_ipv6="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>一般选择 wan 接口，多拨环境请自行选择")

a=s:taboption("content", TextValue, "ipv6_list", translate("IPv6 API列表"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ipv6.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ipv6.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>会因服务器稳定性、连接频繁等原因导致获取失败<br/>如接口可以正常获�?IP，不推荐使用<br/>从以上列表中随机地址访问")
a:depends({pushbot_ipv6="2"})

a=s:taboption("content", Flag,"pushbot_up",translate("设备上线通知"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"pushbot_down",translate("设备下线通知"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"cpuload_enable",translate("CPU 负载报警"))
a.default=1
a.rmempty = true

a= s:taboption("content", Value, "cpuload", "负载报警阈�?)
a.default = 2
a.rmempty = true
a:depends({cpuload_enable="1"})

a=s:taboption("content", Flag,"temperature_enable",translate("CPU 温度报警"))
a.default=1
a.rmempty = true
a.description = translate("请确认设备可以获取温度，如需修改命令，请移步高级设置")

a= s:taboption("content", Value, "temperature", "温度报警阈�?)
a.rmempty = true
a.default = "80"
a.datatype="uinteger"
a:depends({temperature_enable="1"})
a.description = translate("<br/>设备报警只会在连续五分钟超过设定值时才会推�?br/>而且一个小时内不会再提醒第二次")

a=s:taboption("content", Flag,"client_usage",translate("设备异常流量"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "client_usage_max", "每分钟流量限�?)
a.default = "10M"
a.rmempty = true
a:depends({client_usage="1"})
a.description = translate("设备异常流量警报（byte），你可以追�?K 或�?M")

a=s:taboption("content", Flag,"client_usage_disturb",translate("异常流量免打�?))
a.default=1
a.rmempty = true
a:depends({client_usage="1"})

a = s:taboption("content", DynamicList, "client_usage_whitelist", translate("异常流量关注列表"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({client_usage_disturb="1"})
a.description = translate("请输入设�?MAC")

--LoginNoti
a=s:taboption("content", Flag,"web_logged",translate("Web 登录提醒"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_logged",translate("SSH 登录提醒"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"web_login_failed",translate("Web 错误尝试提醒"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_login_failed",translate("SSH 错误尝试提醒"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "login_max_num", "错误尝试次数")
a.default = "3"
a.datatype="and(uinteger,min(1))"
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("超过次数后推送提�?)

a=s:taboption("content", Flag,"web_login_black",translate("自动拉黑"))
a.default=0
a.rmempty = true
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("直到重启前都不会重置次数，请先添加白名单")

a= s:taboption("content", Value, "ip_black_timeout", "拉黑时间(�?")
a.default = "86400"
a.datatype="and(uinteger,min(0))"
a:depends("web_login_black","1")
a.description = translate("0 为永久拉黑，慎用<br>如不幸误操作，请更改设备 IP 进入 LUCI 界面清空规则")

a=s:taboption("content", DynamicList, "ip_white_list", translate("白名�?IP 列表"))
a.datatype = "ipaddr"
a.rmempty = true
luci.ip.neighbors({family = 4}, function(entry)
	if entry.reachable then
		a:value(entry.dest:string())
	end
end)
a:depends("web_logged","1")
a:depends("ssh_logged","1")
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("忽略白名单登陆提醒和拉黑操作，暂不支持掩码位表示")

a=s:taboption("content", TextValue, "ip_black_list", translate("IP 黑名单列�?))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/pushbot/api/ip_blacklist")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/pushbot/api/ip_blacklist", value:gsub("\r\n", "\n"))
end
a:depends("web_login_black","1")

--定时推�?
a=s:taboption("crontab", ListValue,"crontab",translate("定时任务设定"))
a.rmempty = true
a.default=""
a:value("",translate("关闭"))
a:value("1",translate("定时发�?))
a:value("2",translate("间隔发�?))

a=s:taboption("crontab", ListValue,"regular_time",translate("发送时�?))
a.rmempty = true
for t=0,23 do
a:value(t,translate("每天"..t.."�?))
end
a.default=8
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_2",translate("发送时�?))
a.rmempty = true
a:value("",translate("关闭"))
for t=0,23 do
a:value(t,translate("每天"..t.."�?))
end
a.default="关闭"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_3",translate("发送时�?))
a.rmempty = true

a:value("",translate("关闭"))
for t=0,23 do
a:value(t,translate("每天"..t.."�?))
end
a.default="关闭"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"interval_time",translate("发送间�?))
a.rmempty = true
for t=1,23 do
a:value(t,translate(t.."小时"))
end
a.default=6
a.datatype=uinteger
a:depends("crontab","2")
a.description = translate("<br/>�?00:00 开始，�?* 小时发送一�?)

a= s:taboption("crontab", Value, "send_title", translate("推送标�?))
a:depends("crontab","1")
a:depends("crontab","2")
a.placeholder = "OpenWrt By tty228 路由状态："
a.description = translate("<br/>使用特殊符号可能会造成发送失�?)

a=s:taboption("crontab", Flag,"router_status",translate("系统运行情况"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"router_temp",translate("设备温度"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"router_wan",translate("WAN信息"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"client_list",translate("客户端列�?))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Value,"google_check_timeout",translate("全球互联检测超时时�?))
a.rmempty = true
a.optional = false
a.default = "10"
a.datatype = "and(uinteger,min(3))"
a.description = translate("过短的时间可能导致检测不准确")

e=s:taboption("crontab", Button,"_add",translate("手动发�?))
e.inputtitle=translate("发�?)
e:depends("crontab","1")
e:depends("crontab","2")
e.inputstyle = "apply"
function e.write(self, section)
luci.sys.call("cbi.apply")
        luci.sys.call("/usr/bin/pushbot/pushbot send &")
end

--免打�?
a=s:taboption("disturb", ListValue,"pushbot_sheep",translate("免打扰时段设�?),translate("在指定整点时间段内，暂停推送消�?br/>免打扰时间中，定时推送也会被阻止�?))
a.rmempty = true

a:value("",translate("关闭"))
a:value("1",translate("模式一：脚本挂�?))
a:value("2",translate("模式二：静默模式"))
a.description = translate("模式一停止一切检测，包括无人值守�?)
a=s:taboption("disturb", ListValue,"starttime",translate("免打扰开始时�?))
a.rmempty = true

for t=0,23 do
a:value(t,translate("每天"..t.."�?))
end
a.default=0
a.datatype=uinteger
a:depends({pushbot_sheep="1"})
a:depends({pushbot_sheep="2"})
a=s:taboption("disturb", ListValue,"endtime",translate("免打扰结束时�?))
a.rmempty = true

for t=0,23 do
a:value(t,translate("每天"..t.."�?))
end
a.default=8
a.datatype=uinteger
a:depends({pushbot_sheep="1"})
a:depends({pushbot_sheep="2"})

a=s:taboption("disturb", ListValue,"macmechanism",translate("MAC过滤"))
a:value("",translate("disable"))
a:value("allow",translate("忽略列表内设�?))
a:value("block",translate("仅通知列表内设�?))
a:value("interface",translate("仅通知此接口设�?))
a.rmempty = true


a = s:taboption("disturb", DynamicList, "pushbot_whitelist", translate("忽略列表"))
nt.mac_hints(function(mac, name) a :value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="allow"})
a.description = translate("AA:AA:AA:AA:AA:AA\\|BB:BB:BB:BB:BB:B 可以将多�?MAC 视为同一用户<br/>任一设备在线后不再推送，设备全部离线时才会推送，避免�?wifi 频繁推�?)

a = s:taboption("disturb", DynamicList, "pushbot_blacklist", translate("关注列表"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="block"})
a.description = translate("AA:AA:AA:AA:AA:AA\\|BB:BB:BB:BB:BB:B 可以将多�?MAC 视为同一用户<br/>任一设备在线后不再推送，设备全部离线时才会推送，避免�?wifi 频繁推�?)

a = s:taboption("disturb", ListValue, "pushbot_interface", translate("接口名称"))
a:depends({macmechanism="interface"})
a.rmempty = true

for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end

a=s:taboption("disturb", ListValue,"macmechanism2",translate("MAC过滤2"))
a:value("",translate("disable"))
a:value("MAC_online",translate("列表内任意设备在线时免打�?))
a:value("MAC_offline",translate("列表内设备都离线后免打扰"))
a.rmempty = true

a = s:taboption("disturb", DynamicList, "MAC_online_list", translate("在线免打扰列�?))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_online"})

a = s:taboption("disturb", DynamicList, "MAC_offline_list", translate("任意离线免打扰列�?))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_offline"})

s:tab("showdoc", translate("ShowDoc"))
o = s:taboption("showdoc", Flag, "enable_showdoc", translate("���� ShowDoc ����"))
o = s:taboption("showdoc", Value, "showdoc_api_key", translate("API Key"))
o = s:taboption("showdoc", Value, "showdoc_api_token", translate("API Token"))
o = s:taboption("showdoc", Value, "showdoc_item_id", translate("�ĵ� ID"))

return m
