use std::thread::sleep;
use std::time::Duration;

use chrono::prelude::*;

use nature_demo_common::Payment;

use crate::{get_instance_by_id, send_instance};

pub fn send_payment_to_nature(order_id: u128) {
    weit_until_order_account_is_ready(order_id);
    let _first = pay(order_id, 100, "a");
    let _second = pay(order_id, 200, "b");
    let _third = pay(order_id, 700, "c");
    check_order_state(order_id);
}

fn weit_until_order_account_is_ready(order_id: u128) {
    loop {
        if let Some(_) = get_instance_by_id(order_id, "/B/finance/orderAccount:1") {
            break;
        } else {
            sleep(Duration::from_nanos(200000))
        }
    }
}

fn pay(id: u128, num: u32, account: &str) -> u128 {
    let payment = Payment {
        order: id,
        from_account: account.to_string(),
        paid: num,
        pay_time: Local::now().timestamp_millis(),
    };
    send_instance("/finance/payment", &payment).unwrap()
}

fn check_order_state(id: u128) {
    match get_instance_by_id(id, "/B/sale/orderState:1") {
        Some(ins) => {
            assert_eq!(ins.states.contains("paid"), true);
        }
        None => panic!("Should get instance")
    }
}