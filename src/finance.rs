use std::thread::sleep;
use std::time::Duration;

use crate::get_instance_by_id;

pub fn send_payment_to_nature(order_id: u128) {
    weit_until_order_account_is_ready(order_id);
    first_pay();
    second_pay();
    third_pay();
    check_order_state();
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

fn first_pay() {}

fn second_pay() {}

fn third_pay() {}

fn check_order_state() {}