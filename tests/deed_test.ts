import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types,
} from "https://deno.land/x/clarinet@v1.0.2/index.ts";
import { assertEquals } from "https://deno.land/std@0.90.0/testing/asserts.ts";

// Clarinet Default Test
Clarinet.test({
  name: "Ensure that <...>",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let block = chain.mineBlock([
      /*
       * Add transactions with:
       * Tx.contractCall(...)
       */
    ]);
    assertEquals(block.receipts.length, 0);
    assertEquals(block.height, 2);

    block = chain.mineBlock([
      /*
       * Add transactions with:
       * Tx.contractCall(...)
       */
    ]);
    assertEquals(block.receipts.length, 0);
    assertEquals(block.height, 3);
  },
});

//* Stats to Run the test
const contractname = "deed";

const defaultStxVaultAmount = 5000;
const defaultMembers = [
  "deployer",
  "wallet_1",
  "wallet_2",
  "wallet_3",
  "wallet_4",
];
