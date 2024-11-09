// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {FlashLoanReceiverBase} from "./FlashLoanReceiverBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPool} from "./interfaces/IPool.sol";

/**
 * @title FlashLoan
 * @notice Implements flash loan functionality using Aave V3 Protocol
 * @dev Inherits from FlashLoanReceiverBase for base flash loan functionality
 */
contract FlashLoan is FlashLoanReceiverBase {
    using SafeERC20 for IERC20;

    // Events
    event FlashLoanRequested(address[] assets, uint256[] amounts);
    event FlashLoanExecuted(address[] assets, uint256[] amounts, uint256[] premiums);

    // Custom errors
    error CallerNotPool();
    error InvalidArrayLength();
    error InsufficientBalance(address asset, uint256 required, uint256 available);

    constructor(address pool) FlashLoanReceiverBase(pool) {}

    /**
     * @notice Executes operations after receiving the flash loaned amount
     * @param assets The addresses of flash loaned assets
     * @param amounts The amounts of flash loaned assets
     * @param premiums The premiums (fees) to be paid for each asset
     * @param initiator The address that initiated the flash loan
     * @param params The encoded parameters for the flash loan
     * @return success Whether the operation was successful
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // Validate caller
        if (msg.sender != POOL) {
            revert CallerNotPool();
        }

        // Validate array lengths
        if (assets.length != amounts.length || amounts.length != premiums.length) {
            revert InvalidArrayLength();
        }

        // Custom logic goes here
        _executeFlashLoanLogic(assets, amounts, premiums, params);

        // Approve repayment and validate balances
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwed = amounts[i] + premiums[i];
            uint256 balance = IERC20(assets[i]).balanceOf(address(this));
            
            if (balance < amountOwed) {
                revert InsufficientBalance(assets[i], amountOwed, balance);
            }
            
            approveToken(assets[i], amountOwed);
        }

        emit FlashLoanExecuted(assets, amounts, premiums);
        return true;
    }

    /**
     * @notice Initiates a flash loan
     * @param assets The addresses of assets to be flash borrowed
     * @param amounts The amounts of assets to be flash borrowed
     * @param params Additional parameters for the flash loan operation
     */
    function requestFlashLoan(
        address[] calldata assets,
        uint256[] calldata amounts,
        bytes calldata params
    ) external {
        if (assets.length != amounts.length) {
            revert InvalidArrayLength();
        }

        // Create modes array (0 = no debt, 1 = stable, 2 = variable)
        uint256[] memory modes = new uint256[](assets.length);
        // All modes set to 0 for immediate repayment

        emit FlashLoanRequested(assets, amounts);

        IPool(POOL).flashLoan(
            address(this),    // receiverAddress
            assets,          // assets to borrow
            amounts,         // amounts to borrow
            modes,           // modes (0 = no debt)
            address(this),   // onBehalfOf
            params,          // params
            0               // referralCode (currently inactive)
        );
    }

    /**
     * @dev Internal function to execute custom flash loan logic
     * @notice Override this function to implement your custom logic
     */
    function _executeFlashLoanLogic(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        bytes calldata params
    ) internal virtual {
        // Override this function to implement custom logic
    }

    /**
     * @notice Prevents ETH from being stuck in the contract
     */
    receive() external payable {
        revert("Direct ETH deposits not allowed");
    }
} 