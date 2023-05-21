// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DecimalUtils} from "./utils.sol";
import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

interface ICompoundUSDC {
    function supply(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract TestCompoundUSDC is Test {
    using DecimalUtils for uint256;

    // test setup
    string public rpc = vm.envString("MAINNET_RPC_URL");

    // environment
    address public alice;
    address public bob;
    IERC20 public usdc;
    IERC20 public weth;
    ICompoundUSDC public compound;

    function setUp() public {
        // Fork block 17228670
        vm.createSelectFork(rpc, 17228670);

        // setup variables
        alice = address(0x1234);
        bob = address(0x4321);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        compound = ICompoundUSDC(0xc3d688B66703497DAA19211EEdff47f25384cdc3);
    }

    function _getCompoundUSDC(string memory stage) internal view returns (uint256) {
        uint256 balance = usdc.balanceOf(address(compound));
        console.log("* %s", stage);
        console.log("  - USDC(Compound) | %s\n", balance.numberWithCommas(6));
        return balance;
    }

    function testLab7() public {
        // Fork block 17228670
        vm.createSelectFork(rpc, 17228670);

        // Check initial balance
        _getCompoundUSDC("Initial Balance");

        // alice add 1000 USDC liquidity to Compound
        vm.startPrank(alice);
        deal(address(usdc), alice, 1000 * 10 ** 6);
        usdc.approve(address(compound), 1000 * 10 ** 6);
        compound.supply(address(usdc), 1000 * 10 ** 6);

        // Check compound balance
        _getCompoundUSDC("After Alice provides liquidity");

        // Bob supply a lot of WETH to Compound
        changePrank(bob);
        deal(address(weth), bob, 200_000 ether);
        weth.approve(address(compound), 200_000 ether);
        compound.supply(address(weth), 200_000 ether);

        // Bob withdraws all the usdc balance
        compound.withdraw(address(usdc), usdc.balanceOf(address(compound)));

        // Check compound balance (may close to 0)
        _getCompoundUSDC("After Bob withdraws all the usdc balance");

        // Alice try to withdraw 1000USDC
        changePrank(alice);
        compound.withdraw(address(usdc), 1000 * 10 ** 6);
    }
}
