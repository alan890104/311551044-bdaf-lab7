// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Library for handling decimals and formatting
library DecimalUtils {
    // Returns a string representation of `val` formatted with commas for readability
    // and a decimal point inserted `decimals` places from the right.
    // For example, numberWithCommas(255576801746570, 6) returns "255,576,801.746570".
    function numberWithCommas(uint256 val, uint8 decimals) internal pure returns (string memory) {
        if (val == 0) {
            return "0";
        }
        string memory strVal = toString(val);
        uint256 valLength = bytes(strVal).length;

        uint256 afterDecimalLength = decimals;
        uint256 beforeDecimalLength = valLength - afterDecimalLength;

        bytes memory afterDecimal = new bytes(afterDecimalLength);
        for (uint256 i = 0; i < afterDecimalLength; i++) {
            afterDecimal[i] = bytes(strVal)[valLength - decimals + i];
        }

        bytes memory beforeDecimal = new bytes(beforeDecimalLength);
        for (uint256 i = 0; i < beforeDecimalLength; i++) {
            beforeDecimal[i] = bytes(strVal)[i];
        }

        string memory beforeDecimalStr = string(beforeDecimal);
        string memory afterDecimalStr = string(afterDecimal);

        return string(abi.encodePacked(addCommas(beforeDecimalStr), ".", afterDecimalStr));
    }

    // Converts a uint256 to a string
    function toString(uint256 val) internal pure returns (string memory) {
        if (val == 0) {
            return "0";
        }
        uint256 tempVal = val;
        uint256 digits;
        while (tempVal != 0) {
            digits++;
            tempVal /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (val != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(val % 10)));
            val /= 10;
        }
        return string(buffer);
    }

    // Inserts commas into a string representing a decimal number
    // For example, addCommas("1234567") returns "1,234,567".
    function addCommas(string memory val) internal pure returns (string memory) {
        bytes memory valBytes = bytes(val);
        uint256 length = valBytes.length;

        uint256 numCommas = (length - 1) / 3;
        uint256 resultLength = length + numCommas;
        bytes memory result = new bytes(resultLength);

        uint256 j = resultLength;
        for (uint256 i = length; i > 0; i--) {
            if ((length - i) % 3 == 0 && j != resultLength) {
                result[--j] = bytes1(",");
            }
            result[--j] = valBytes[i - 1];
        }

        return string(result);
    }
}
