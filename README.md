# Ubuntu Single User Nix Inside Podman

在 podman 容器里运行一个带 systemd 的 Ubuntu，并为单用户安装 Nix（`--no-daemon`），支持 SSH 登录。

## 特性

- systemd 作为 PID 1
- 单用户模式安装 Nix
- 默认开启 SSH
- 家目录（`/home`）和 Nix store（`/nix`）使用命名卷持久化
- 支持 KVM（rootless podman 下通过 `keep-groups` 自动继承宿主机的 `kvm` 组）

## 前提

- podman
- podman-compose

## 快速开始

```bash
# 1. 复制到 local 以按需修改
cp Containerfile local/Containerfile
cp compose.yaml local/compose.yaml

# 2. 构建并启动
cd local
podman-compose up -d --build

# 3. SSH 登录
ssh -p 57307 ubuntu@127.0.0.1
```

## 注意事项

### 卷只在首次启动时填充

`home` 和 `nix` 命名卷会在**首次**启动时从镜像拷贝内容，之后持久化。因此：

- 改了 Containerfile 并重新构建后，旧卷仍保留旧内容，不会自动更新
- 想要完全重建请删除卷后重新 `up`：

```bash
cd local
podman-compose down
# 具体名字看 podman volume ls
podman volume rm ubuntu-single-user-nix-inside-podman_home ubuntu-single-user-nix-inside-podman_nix
podman-compose up -d --build
```

### 软件包和 SSH host key 更新

构建层缓存会让 apt 包停留在首次构建的版本。需要升级时强制重建：

```bash
cd local
podman-compose build --no-cache --pull
podman-compose up -d --force-recreate
```

`openssh-server` 在安装时生成的 host key 同样写入镜像，只要镜像不重建，key 就不会变，可能需要使用上述命令解决特定安全问题。
