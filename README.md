# fat

fast lua(u) decompiler. forked from [medal](https://github.com/shrimp-nz/medal).

made by **bisam**

## install

one command, works on termux, linux and mac. grabs the right binary for your system automatically.

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
```

or clone it first if you want:

```bash
git clone https://github.com/DexCodeSX/fat.git
cd fat
chmod +x setup.sh
./setup.sh
```

thats it. binary goes to `~/medal`.

### termux (android)

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
cd ~
./medal serve
```

setup.sh will ask for storage permission automatically. if you wanna expose the server so your executor can reach it, use ngrok:

```bash
pkg install ngrok
ngrok http 3000
```

then copy the ngrok url into the gui script or your executor.

### linux

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
cd ~
./medal serve
```

if you want it in your PATH:

```bash
sudo mv ~/medal /usr/local/bin/medal
medal serve
```

### macos

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
cd ~
./medal serve
```

if macos blocks it (gatekeeper):

```bash
xattr -d com.apple.quarantine ~/medal
```

## usage

```
./medal decompile -i script.bin -o output.lua
./medal serve --port 3000
./medal help
```

## releases

prebuilt binaries on the [releases page](https://github.com/DexCodeSX/fat/releases):

| file | platform |
|------|----------|
| `medal-aarch64-android` | termux / android (arm64) |
| `medal-x86_64-linux-musl` | linux (x86_64, static) |
| `medal-x86_64-macos` | macos intel |
| `medal-aarch64-macos` | macos apple silicon |

only 64-bit supported. if you're on 32-bit you're out of luck sorry.

## script

when using `medal serve`, you can use the decompiler straight from your executor.
these scripts assume you're self-hosting. if you're using an API or ngrok, swap out `http://localhost:3000` with whatever your actual url is.

### windows

run `medal serve` on your pc, then in your executor:

```lua
getgenv().decompile = function(script_instance)
  local bytecode = getscriptbytecode(script_instance)
  local encoded = crypt.base64encode(bytecode)
  return request(
    {
      Url = "http://localhost:3000/luau/decompile",
      Method = "POST",
      Body = encoded
    }
  ).Body
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()({
  mode = "scripts",
  NilInstances = true,
})
```

### android (real device, not emulator)

run `medal serve` on termux, use ngrok to get a public url, then in your executor:

```lua
getgenv().decompile = function(script_instance)
  local bytecode = getscriptbytecode(script_instance)
  local encoded = crypt.base64encode(bytecode)
  return request(
    {
      Url = "https://your-ngrok-url.ngrok-free.app/luau/decompile",
      Method = "POST",
      Body = encoded
    }
  ).Body
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()({
  mode = "scripts",
  NilInstances = true,
})
```

### android emulator

> **heads up:**
> - if you got a proxy in wifi settings, add `10.0.2.2` to exceptions or just turn it off
> - if you're on a VPN, make sure LAN connections are allowed

run the server on your actual pc (not inside the emulator). `localhost` inside the emulator points to the emulator itself, not your pc. use `10.0.2.2` instead - thats how android emulators reach the host machine.

test it: open `http://10.0.2.2:3000/` in the emulator browser. if it loads, you're good.

if it still doesnt work, try ngrok instead.

```lua
getgenv().decompile = function(script_instance)
  local bytecode = getscriptbytecode(script_instance)
  local encoded = crypt.base64encode(bytecode)
  return request(
    {
      Url = "http://10.0.2.2:3000/luau/decompile",
      Method = "POST",
      Body = encoded
    }
  ).Body
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()({
  mode = "scripts",
  NilInstances = true,
})
```

### gui script

theres a full gui in `gui.luau` - has connection settings, one-click decompile, save instance, the whole thing. just load it in your executor.

## docker

```bash
docker build -t fat .
docker run -p 3000:3000 fat
```

## building from source

if you wanna build it yourself instead of using the prebuilt binaries:

```bash
# needs rust nightly
rustup default nightly
cargo build --release --bin medal
# binary is at target/release/medal
```

## license

original [medal license](https://github.com/shrimp-nz/medal/blob/main/LICENSE.txt) (MIT) is kept for reference. this fork is **GPL v3** so people cant just take it and sell it.

## credits

made by **bisam**

original medal by:
- Jujhar Singh (KowalskiFX)
- Mathias Pedersen (Customality)

rest in peace. keep the Singh and Pedersen families in your prayers.
