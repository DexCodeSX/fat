# fat

fast lua(u) decompiler. forked from [medal](https://github.com/shrimp-nz/medal).

made by **bisam**

## install

one command. works on termux, linux and mac. picks the right binary for your system.

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
```

or clone it:

```bash
git clone https://github.com/DexCodeSX/fat.git
cd fat
chmod +x setup.sh
./setup.sh
```

binary goes to `~/medal`. thats it.

## update

same command. it checks what you have and only downloads if theres a new version.

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
```

## setup by platform

### termux (android)

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
cd ~
./medal serve
```

storage permission gets requested automatically. to expose the server so your executor can reach it use ngrok:

```bash
pkg install ngrok
ngrok http 3000
```

copy the ngrok url into gui.luau or your executor script.

### linux

```bash
curl -sL https://raw.githubusercontent.com/DexCodeSX/fat/main/setup.sh | bash
cd ~
./medal serve
```

want it in PATH:

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

if gatekeeper blocks it:

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
| `medal-x86_64.exe` | windows 64-bit |
| `medal-aarch64-android` | termux / android (arm64) |
| `medal-x86_64-linux-musl` | linux (x86_64, static linked) |
| `medal-x86_64-macos` | macos intel |
| `medal-aarch64-macos` | macos apple silicon (M1/M2/M3/M4) |

64-bit only. 32-bit not supported.

### how to release (for devs)

push a version tag and github actions builds everything automatically:

```bash
git tag v0.1.2
git push origin v0.1.2
```

builds all 4 binaries and uploads them to a release. done.

## script

when using `medal serve`, you can decompile straight from your executor.
if you're using ngrok or some API, swap `http://localhost:3000` with your actual url.

### windows

run `medal serve` on your pc, then in executor:

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

### android (real device)

run `medal serve` on termux, get a public url with ngrok, then:

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
> - proxy in wifi settings? add `10.0.2.2` to exceptions or turn it off
> - VPN on? allow LAN connections

run the server on your actual pc. `localhost` inside an emulator means the emulator itself not your pc. use `10.0.2.2` - thats how emulators talk to the host machine.

quick test: open `http://10.0.2.2:3000/` in the emulator browser. if it loads you're good. if not try ngrok.

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

full gui with tabs, connection settings, one-click decompile, save instance, built-in code editor with syntax highlighting and line numbers. load it in your executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/DexCodeSX/fat/main/gui.luau"))()
```

the gui has a settings tab where you type in your server host (ngrok url, localhost, whatever) and pick http or https. hit connect, go to decompile tab, paste a script path, hit decompile. opens a full notepad editor with the result - you can copy it or save to file.

## docker

```bash
docker build -t fat .
docker run -p 3000:3000 fat
```

## building from source

```bash
rustup default nightly
cargo build --release --bin medal
# binary at target/release/medal
```

## license

original [medal license](https://github.com/shrimp-nz/medal/blob/main/LICENSE.txt) (MIT) kept for reference. this fork is **GPL v3** so nobody can just sell it.

## credits

made by **bisam**

original medal by:
- Jujhar Singh (KowalskiFX)
- Mathias Pedersen (Customality)

rest in peace. keep the Singh and Pedersen families in your prayers.
