/etc/ipsec.conf文件配置如下：

```
# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
	# strictcrlpolicy=yes
	# uniqueids = no

# Add connections here.

conn sjtu
	left=%config
	leftsourceip=%config
	leftauth=eap-gtc
	right=stu.vpn.sjtu.edu.cn
	rightsubnet=0.0.0.0/0
	rightid=@stu.vpn.sjtu.edu.cn
	rightauth=pubkey
	eap_identity=jAccount
	auto=add
```

/etc/ipsec.secrets文件配置如下：

```
jAccount : EAP "Your Password"
```

```
sudo cp -r /etc/ssl/certs/* /etc/ipsec.d/cacerts
```

```
sudo ipsec start
sudo ipsec up sjtu
```

https://jachinshen.github.io/environment/2018/09/26/Linux%E4%B8%ADIKEv2%E6%96%B9%E5%BC%8FEAP%E8%BF%9E%E6%8E%A5VPN.html

