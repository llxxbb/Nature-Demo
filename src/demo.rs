use nature_common::ParaForQueryByID;

use crate::{CLIENT, outbound, send_order_to_nature, URL_GET_BY_ID, user_pay, wait_for_order_state};

#[test]
fn demo_all_test() {
    dbg!("generate order");
    let id = send_order_to_nature();
    dbg!("pay for order");
    user_pay(id);
//    dbg!("package and outbound");
//    outbound(id);
//    dbg!("delay for auto signed");
//    let _ = wait_for_order_state(id, 5);
}

#[test]
fn temp_test() {
    let response = CLIENT.post(URL_GET_BY_ID).json(&ParaForQueryByID {
        id: 271448073389351988786345053349058430028,
        meta: "B:sale/orderState:1".to_string(),
        state_version_from: 0,
        limit: 1,
    }).send();
    let msg = response.unwrap().text().unwrap();
    assert_eq!(msg.contains("271448073389351988786345053349058430028"), true);
}