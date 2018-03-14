###### README.

1.调用请求权限的方法之前，需要先在Info.plist文件中配置2个KV，特别是第一个Key，不可缺失.
Privacy - Location Always and When In Use Usage Description
Privacy - Location When In Use Usage Description
2.调用反地理编码会产生网络请求，需要网络权限.
3.若请求权限时，系统定位服务未开启，则需要添加一下应用进入前后台的监听方法（退到后台时添加回到前台的方法，
回到前台之后，移除监听对象），以在应用回到前台时判定发现定位服务已开启的情况下重新调用请求权限的方法.
4.如果需要后台持续定位，则需要先将Capabilities中的Background Modes中的Location Updates选项打开.
