use std::io::{Write, stdout};

const RST: &str = "\x1b[0m";
const BOLD: &str = "\x1b[1m";
const DIM_S: &str = "\x1b[2m";
const PRP: &str = "\x1b[38;5;141m";
const GRN: &str = "\x1b[38;5;84m";
const RED: &str = "\x1b[38;5;196m";
const WHT: &str = "\x1b[38;5;255m";
const GRY: &str = "\x1b[38;5;245m";
const CYN: &str = "\x1b[38;5;87m";
const LINE: &str = "\x1b[38;5;240m";

pub fn banner() {
    let mut o = stdout();
    let _ = write!(o, "\x1b[2J\x1b[H");
    let _ = o.flush();

    std::thread::sleep(std::time::Duration::from_millis(50));

    println!();
    println!("{PRP}{BOLD}    ___       __        __  ");
    println!("   / __\\__ _ / /_      / /  ");
    println!("  / _\\/ _` | __|_____/ /   ");
    println!(" / / | (_| | ||_____/ /    ");
    println!(" \\/   \\__,_|\\__|   /_/     {RST}");
    println!();
    println!("  {DIM_S}{GRY}Lua(u) Decompiler{RST}  {PRP}│{RST}  {DIM_S}{GRY}Made by bisam{RST}");
    println!("  {LINE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RST}");
    println!();
}

pub fn info(msg: &str) {
    println!("  {PRP}▸{RST} {WHT}{msg}{RST}");
}

pub fn dim(msg: &str) {
    println!("  {GRY}  {msg}{RST}");
}

pub fn success(msg: &str) {
    println!("  {GRN}✓{RST} {WHT}{msg}{RST}");
}

pub fn error(msg: &str) {
    println!("  {RED}✗{RST} {RED}{msg}{RST}");
}

pub fn spin_start(msg: &str) {
    let mut o = stdout();
    let _ = write!(o, "  {CYN}⠹{RST} {WHT}{msg}...{RST}");
    let _ = o.flush();
}

pub fn spin_done(msg: &str) {
    let mut o = stdout();
    let _ = write!(o, "\r  {GRN}✓{RST} {WHT}{msg}{RST}                    \n");
    let _ = o.flush();
}

pub fn spin_fail(msg: &str) {
    let mut o = stdout();
    let _ = write!(o, "\r  {RED}✗{RST} {RED}{msg}{RST}                    \n");
    let _ = o.flush();
}
