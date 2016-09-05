# uscfun
usc日常ios前端

首先更新Xcode到最新版本

然后使用 CocoaPods 进行安装。如果尚未安装 CocoaPods，运行以下命令进行安装：

```shell
gem install cocoapods
```

然后进入到Project根目录下运行
```shell
pod install
```

如果耗时太长，建议使用如下方式：

```shell
 # 禁止升级 CocoaPods 的 spec 仓库，否则会卡在 Analyzing dependencies，非常慢
 pod update --verbose --no-repo-update
```

如果提示找不到库，则可去掉 `--no-repo-update`。

依赖包安装完成后，用Xcode打开 uscfun.xcworkspace 而不是uscfun.xcodeproj，用数据线连接到自己的手机，点击Xcode Run即可。
