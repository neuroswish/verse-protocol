// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

library Math {
    // ============ Library Functions ============

    /*
     * Return (target * numerator) / (denominator).
     */
    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {
        return (target * numerator) / (denominator);
    }
}