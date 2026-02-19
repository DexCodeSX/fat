use clap::Parser;
use std::io::{Write, stdout};
use std::time::Instant;

use crate::commands::{Cli, decompile, serve};

mod commands;
mod ui;

#[tokio::main]
async fn main() -> Result<(), std::io::Error> {
    let subscriber = tracing_subscriber::fmt()
        .compact()
        .with_file(true)
        .with_line_number(true)
        .with_thread_ids(true)
        .with_target(false)
        .finish();
    tracing::subscriber::set_global_default(subscriber)
        .expect("failed to set global tracing subscriber");

    ui::banner();

    let cli = Cli::parse();
    match cli.command {
        commands::Commands::Decompile {
            input,
            output,
            encode_key,
            lua51,
        } => {
            let mode = if lua51 { "Lua 5.1" } else { "Luau" };
            ui::info(&format!("Mode: {}", mode));
            ui::info(&format!("Input: {}", input.display()));
            ui::info(&format!("Output: {}", output.display()));
            if !lua51 {
                ui::dim(&format!("Encode key: {}", encode_key));
            }
            println!();

            let t = Instant::now();
            ui::spin_start("Decompiling bytecode");
            let res = decompile(&input, &output, encode_key, lua51);
            let elapsed = t.elapsed();

            match res {
                Ok(()) => {
                    ui::spin_done("Decompilation complete");
                    let sz = std::fs::metadata(&output).map(|m| m.len()).unwrap_or(0);
                    ui::success(&format!(
                        "Output: {} ({} bytes, {:.2}s)",
                        output.display(),
                        sz,
                        elapsed.as_secs_f64()
                    ));
                }
                Err(e) => {
                    ui::spin_fail("Decompilation failed");
                    ui::error(&format!("{}", e));
                    std::process::exit(1);
                }
            }
        }
        commands::Commands::Serve { port, luau, lua51 } => {
            ui::info(&format!("Starting server on port {}", port));
            ui::dim(&format!(
                "Endpoints: {}{}",
                if luau { "/luau/decompile " } else { "" },
                if lua51 { "/lua51/decompile" } else { "" }
            ));
            println!();

            let mut out = stdout();
            write!(out, "  \x1b[38;5;84m●\x1b[0m \x1b[38;5;255mServer ready at \x1b[38;5;141mhttp://0.0.0.0:{}\x1b[0m\n\n", port)?;
            out.flush()?;

            serve(port, luau, lua51).await?;
        }
    }

    Ok(())
}
