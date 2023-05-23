# 311551044-BDAF-LAB7

[Lab7 description](https://bdaf.notion.site/Lab7-What-happens-when-Compound-has-no-liquidity-0a31a21324b44cd39279a51749d7047a)

[My Implementation](https://github.com/alan890104/311551044-bdaf-lab7/blob/master/test/lab7.t.sol)

## Run test

1. Fill in env vars

    ```bash
    cp .env.example .env
    ```

2. Run test (with traces)

    ```bash
    forge test -vvvv
    ```

## Steps to reproduce

1. Fork block `17228670` by foundry built-in fork function

    ```solidity
     vm.createSelectFork(rpc, 17228670);
    ```

    ![alt text](/image/lab7-step1.png)

2. Mint `1000 USDC` to alice (USDC has decimals 6)

    ```solidity
    vm.startPrank(alice);
    deal(address(usdc), alice, 1000 * 10 ** 6);
    ```

3. Alice add `1000 USDC` liquidity to Compound

   ```solidity
   usdc.approve(address(compound), 1000 * 10 ** 6);
   compound.supply(address(usdc), 1000 * 10 ** 6);
   ```
   ![alt text](/image/lab7-step2.png)

4. Mint `200,000 WETH` to Bob

    ```solidity
    changePrank(bob);
    deal(address(weth), bob, 200_000 ether);
    ```

5. Bob supply `200,000 WETH` to Compound

    ```solidity
    weth.approve(address(compound), 200_000 ether);
    compound.supply(address(weth), 200_000 ether);
    ```

6. Bob withdraws all the usdc from Compound

    ```solidity
    compound.withdraw(address(usdc), usdc.balanceOf(address(compound)));
    ```

    ![alt text](/image/lab7-step3.png)

7. Alice try to withdraw `1000 USDC` from Compound, but she will get `ERC20: transfer amount exceeds balance` error

    ```solidity
    changePrank(alice);
    uint256 remain = compound.balanceOf(address(alice));
    vm.expectRevert(BorrowTooSmall.selector);
    compound.withdraw(address(usdc), remain);
    ```

    ![alt text](/image/lab7-step4.png)