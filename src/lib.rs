#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate log;
#[cfg(test)]
#[macro_use]
extern crate serde_derive;

pub use common::*;

mod common;
#[cfg(test)]
mod emall;
#[cfg(test)]
mod score;
#[cfg(test)]
mod sale_statistics;
#[cfg(test)]
mod other;
#[cfg(test)]
mod multi_warehouse;
#[cfg(test)]
mod multi_delivery;