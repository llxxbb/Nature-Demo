use std::str::FromStr;

use nature::common::NatureError;

#[test]
fn u128_test() {
    let id = "23161777138351926403917145131788703064";
    let result = u128::from_str(id).unwrap();
    assert_eq!(result, 23161777138351926403917145131788703064);
    let id = r#"{"Ok":23161777138351926403917145131788703064}"#;
    let result: Result<u128, NatureError> = serde_json::from_str(&id).unwrap();
    assert_eq!(result.unwrap(), 23161777138351926403917145131788703064);
}
