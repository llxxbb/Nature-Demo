# Generate order

We suppose the user have goods selected, and use it to generate an order.

### Define `meta`s

First we will define two `meta`s. please insert the follow data to nature.sqlite.

- /B/sale/order: includes normal order properties.

- /B/sale/orderState: the status for new, paid, outbound, dispatching, signed etcetera.

  ```sqlite
  INSERT INTO meta
  (full_key, description, version, states, fields, config)
  VALUES('/B/sale/order', 'order', 1, '', '', '{}');
  
  INSERT INTO meta
  (full_key, description, version, states, fields, config)
  VALUES('/B/sale/orderState', 'order state', 1, 'new,paid,picked,outbound,dispatching,signed', '', '{}');
  ```

### Nature key points

In tradition design, order and order state will be fill into one table, in this condition, new state will overwrite the old one, so it's difficult to trace the changes. In Nature, normal data and state data are separated strictly, You must define them separately. And furthermore, Nature will trace every change for the state data.

## Define converter

When we input an `Order` from outside, we set a `new` state for this order by converter. Execute the following sql please:



