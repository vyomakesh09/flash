// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlashLoanReceiver} from "./interfaces/IFlashLoanReceiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title FlashLoanReceiverBase
 * @notice Base contract for flash loan receivers
 */
abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
    using SafeERC20 for IERC20;

    address public immutable POOL;

    constructor(address pool) {
        require(pool != address(0), "Invalid pool address");
        POOL = pool;
    }

    /**
     * @notice Approves the Pool to spend tokens
     * @param token The token to approve
     * @param amount The amount to approve
     */
    function approveToken(address token, uint256 amount) internal {
        IERC20(token).safeApprove(POOL, 0);
        IERC20(token).safeApprove(POOL, amount);
    }

    /**
     * @notice Rescues stuck tokens
     * @param token The token to rescue
     * @param to The address to send the tokens to
     * @param amount The amount to rescue
     */
    function rescueTokens(
        address token,
        address to,
        uint256 amount
    ) external virtual {
        require(msg.sender == POOL, "Only Pool can rescue tokens");
        IERC20(token).safeTransfer(to, amount);
    }
} 