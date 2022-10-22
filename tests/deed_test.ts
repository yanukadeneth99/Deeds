import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types,
} from "https://deno.land/x/clarinet@v1.0.2/index.ts";
import { assertEquals } from "https://deno.land/std@0.90.0/testing/asserts.ts";

//* Clarinet Default Test
Clarinet.test({
  name: "Ensure that contract works",
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
const contractName = "deed";

const defaultStxVaultAmount = 5000;
const defaultMembers = [
  "deployer",
  "wallet_1",
  "wallet_2",
  "wallet_3",
  "wallet_4",
];

/*
- Error List -

err u100 - Deed is not listed for sale
err u101 - Deed is listed for sale
err u102 - Deed does not exist
err u103 - Deed already exists
err u104 - Invalid Value in a Tuple
err u105 - Not the Deed Owner
err u106 - Price is zero or not enough
*/

//* Accessing all the functions using the Deed ID #1
Clarinet.test({
  name: "Cannot access any function without creating a deed",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let wallet1 = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      // Transfer Deed
      Tx.contractCall(
        contractName,
        "transfer-deed",
        [types.principal(wallet1.address), types.uint(1)],
        deployer.address
      ),
      // Listing for sale
      Tx.contractCall(
        contractName,
        "list-for-sale",
        [types.uint(1), types.uint(100)],
        deployer.address
      ),
      // Unlisting from sale
      Tx.contractCall(
        contractName,
        "unlist-for-sale",
        [types.uint(1)],
        deployer.address
      ),
      // Buy Deed
      Tx.contractCall(
        contractName,
        "buy-deed",
        [types.uint(1)],
        deployer.address
      ),
      // Change Price
      Tx.contractCall(
        contractName,
        "change-price",
        [types.uint(1), types.uint(500)],
        deployer.address
      ),
      // Change Images
      Tx.contractCall(
        contractName,
        "change-images",
        [types.uint(1), types.ascii("Test")],
        deployer.address
      ),
      // Change Name
      Tx.contractCall(
        contractName,
        "change-name",
        [types.uint(1), types.ascii("Test")],
        deployer.address
      ),
      // Change Bedroom
      Tx.contractCall(
        contractName,
        "change-bedroom",
        [types.uint(1), types.uint(4)],
        deployer.address
      ),
      // Change Bathroom
      Tx.contractCall(
        contractName,
        "change-bathroom",
        [types.uint(1), types.uint(4)],
        deployer.address
      ),
      // Change Size
      Tx.contractCall(
        contractName,
        "change-size",
        [types.uint(1), types.uint(200), types.uint(200)],
        deployer.address
      ),
      // Get Deed
      Tx.contractCall(
        contractName,
        "get-deed",
        [types.uint(1)],
        deployer.address
      ),
    ]);

    // Transfer Should Fail
    block.receipts[0].result.expectErr().expectUint(102);
    // Listing should fail
    block.receipts[1].result.expectErr().expectUint(102);
    // Unlist should fail
    block.receipts[2].result.expectErr().expectUint(102);
    // Buy Deed should fail
    block.receipts[3].result.expectErr().expectUint(102);
    // Changing Price should fail
    block.receipts[4].result.expectErr().expectUint(102);
    // Changing Images should fail
    block.receipts[5].result.expectErr().expectUint(102);
    // Changing Name should fail
    block.receipts[6].result.expectErr().expectUint(102);
    // Changing Bedroom should fail
    block.receipts[7].result.expectErr().expectUint(102);
    // Changing Bathroom should fail
    block.receipts[8].result.expectErr().expectUint(102);
    // Changing Size
    block.receipts[9].result.expectErr().expectUint(102);
    // Getting Deed
    block.receipts[10].result.expectErr().expectUint(102);
  },
});

//* Creating a Deed starting from incorrect values
Clarinet.test({
  name: "Creating a Deed starting from incorrect values",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;

    let block = chain.mineBlock([
      // Create a Deeds Incorrectly
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii(""), // Name
          types.ascii(""), // Image URL
          types.uint(0), // Bedroom
          types.uint(0), // Bathroom
          types.uint(0), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii(""), // Image URL
          types.uint(0), // Bedroom
          types.uint(0), // Bathroom
          types.uint(0), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(0), // Bedroom
          types.uint(0), // Bathroom
          types.uint(0), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(1), // Bedroom
          types.uint(0), // Bathroom
          types.uint(0), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(0), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(500), // Size X
          types.uint(0), // Size Y
        ],
        deployer.address
      ),
      // Valid Transaction
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(500), // Size X
          types.uint(500), // Size Y
        ],
        deployer.address
      ),
    ]);

    // Incorrect Ones
    block.receipts[0].result.expectErr().expectUint(104);
    block.receipts[1].result.expectErr().expectUint(104);
    block.receipts[2].result.expectErr().expectUint(104);
    block.receipts[3].result.expectErr().expectUint(104);
    block.receipts[4].result.expectErr().expectUint(104);
    block.receipts[5].result.expectErr().expectUint(104);

    // Correct one
    block.receipts[6].result.expectOk();
  },
});

//* Creating a Deed and changing information
Clarinet.test({
  name: "Creating a Deed and changing information",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;

    let block = chain.mineBlock([
      // Valid Transaction
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("Name"), // Name
          types.ascii("URL"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(500), // Size X
          types.uint(500), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "get-deed",
        [types.uint(1)],
        deployer.address
      ),
      // Changing Price
      Tx.contractCall(
        contractName,
        "change-price",
        [types.uint(1), types.uint(500)],
        deployer.address
      ),
      // Changing Images URL
      Tx.contractCall(
        contractName,
        "change-images",
        [types.uint(1), types.ascii("https://google.com")],
        deployer.address
      ),
      // Changing Images URL
      Tx.contractCall(
        contractName,
        "change-name",
        [types.uint(1), types.ascii("Jake")],
        deployer.address
      ),
      // Changing Bedroom Count
      Tx.contractCall(
        contractName,
        "change-bedroom",
        [types.uint(1), types.uint(4)],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "change-bathroom",
        [types.uint(1), types.uint(2)],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "change-size",
        [types.uint(1), types.uint(200), types.uint(200)],
        deployer.address
      ),
    ]);

    // Created Deed
    block.receipts[0].result.expectOk();
    // Getting Deed by ID
    block.receipts[1].result.expectOk().expectTuple();
    // Changing Price
    block.receipts[2].result.expectOk();
    // Changing Image URL
    block.receipts[3].result.expectOk();
    // Changing Name
    block.receipts[4].result.expectOk();
    // Changing Bedroom count
    block.receipts[5].result.expectOk();
    // Changing Bathroom count
    block.receipts[6].result.expectOk();
    // Changing Size
    block.receipts[7].result.expectOk();
  },
});

//* Listing a Deed and Selling it
Clarinet.test({
  name: "Listing a Deed and selling it",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let buyer = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      // Valid Transaction
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("House"), // Name
          types.ascii("https://google.com"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(500), // Size X
          types.uint(500), // Size Y
        ],
        deployer.address
      ),
      // Listing House for Sale
      Tx.contractCall(
        contractName,
        "list-for-sale",
        [
          types.uint(1), // ID
          types.uint(1200), // Price
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "get-owner",
        [
          types.uint(1), // ID
        ],
        deployer.address
      ),
      // Buying Deed
      Tx.contractCall(contractName, "buy-deed", [types.uint(1)], buyer.address),
      Tx.contractCall(
        contractName,
        "get-owner",
        [
          types.uint(1), // ID
        ],
        deployer.address
      ),
    ]);

    // Created Deed
    block.receipts[0].result.expectOk();
    // Listing Deed
    block.receipts[1].result.expectOk();
    // Checking Address before transfer
    block.receipts[2].result.expectOk().expectPrincipal(deployer.address);
    // Buying Deed
    block.receipts[3].events.expectSTXTransferEvent(
      1200,
      buyer.address,
      deployer.address
    );
    // Confirming Address after transfer
    block.receipts[4].result.expectOk().expectPrincipal(buyer.address);
  },
});

//* Trying to change information on an unowned deed

//* Transferring Deed
Clarinet.test({
  name: "Transfer Deed",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let buyer = accounts.get("wallet_1")!;

    let block = chain.mineBlock([
      // Valid Transaction
      Tx.contractCall(
        contractName,
        "create-deed",
        [
          types.ascii("House"), // Name
          types.ascii("https://google.com"), // Image URL
          types.uint(1), // Bedroom
          types.uint(2), // Bathroom
          types.uint(500), // Size X
          types.uint(500), // Size Y
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "get-owner",
        [
          types.uint(1), // ID
        ],
        deployer.address
      ),
      // Transfer Deed
      Tx.contractCall(
        contractName,
        "transfer-deed",
        [
          types.principal(buyer.address), // Transfer Account
          types.uint(1), // ID
        ],
        deployer.address
      ),
      Tx.contractCall(
        contractName,
        "get-owner",
        [
          types.uint(1), // ID
        ],
        deployer.address
      ),
    ]);

    // Created Deed
    block.receipts[0].result.expectOk();
    // Checking the Owner before transfer
    block.receipts[1].result.expectOk().expectPrincipal(deployer.address);
    // Transferred Ownership
    block.receipts[2].result.expectOk();
    // Checking the Owner after transfer
    block.receipts[3].result.expectOk().expectPrincipal(buyer.address);
  },
});
