use std::collections::HashMap;
use std::thread::sleep;
use std::time::Duration;

use chrono::prelude::*;

use nature_demo_common::Payment;

use crate::{get_instance_by_id, send_business_object_with_context, wait_for_order_state};

pub fn user_pay(order_id: u128) {
    wait_until_order_account_is_ready(order_id);
    let _first = pay(order_id, 100, "a", Local::now().timestamp_millis());
    let time = Local::now().timestamp_millis();
    let _second = pay(order_id, 200, "b", time);
    let _third = pay(order_id, 700, "c", Local::now().timestamp_millis());
    let _second_repeat = pay(order_id, 200, "b", time);
    let _ = wait_for_order_state(order_id, 2);
}

fn wait_until_order_account_is_ready(order_id: u128) {
    loop {
        if let Some(_) = get_instance_by_id(order_id, "/B/finance/orderAccount:1") {
            break;
        } else {
            sleep(Duration::from_nanos(200000))
        }
    }
}

fn pay(id: u128, num: u32, account: &str, time: i64) -> u128 {
    let payment = Payment {
        order: id,
        from_account: account.to_string(),
        paid: num,
        pay_time: time,
    };
    let mut context: HashMap<String, String> = HashMap::new();
    context.insert("sys.target".to_string(), id.to_string());
    match send_business_object_with_context("/finance/payment", &payment, &context) {
        Ok(id) => id,
        _ => 0
    }
}

