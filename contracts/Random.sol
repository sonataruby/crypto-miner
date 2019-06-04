pragma solidity 0.5.8;

/**
 * @title Random Library
 *
 * @notice Library for working with random numbers
 *
 * @author Basil Gorin
 */
library Random {
  /**
   * @notice Uniform random distribution implementation, generates random number
   *      in range [0, n)
   * @dev Based on the external source of randomness - `rnd256`
   * @param rnd256 source of randomness – up to 256 bits of random data,
   *      can be generated by `generate256` function
   * @param b number of bits to use in rnd256, zero means use all 256 bits
   * @param n number of possible output values, upper bound is `n - 1`
   * @return a random value in range [0, n), uniform distribution
   */
  function uniform(uint256 rnd256, uint8 b, uint256 n) internal pure returns (uint256) {
    // calculate the mask based on number of bits
    // if b is zero its same as 256, which is full mask
    uint256 mask = b == 0? uint256(-1): (uint256(1) << b) - 1; // uint256(-1) overflows to 0xFFFF...

    // arithmetic overflow check
    require(mask * n / n == mask, "arithmetic overflow: reduce b or/and n");

    // return random value in range [0, n)
    return (mask & rnd256) * n / (mask + 1);
  }

  /**
   * @notice Quadratic random distribution implementation, generates random number
   *      in range [0, n), the distribution is quadratic, not uniform
   * @dev Based on the external source of randomness - `rnd256`
   * @dev Internally the source of randomness is split into two halves
   *      and multiplication of the halves is used, so be sure to provide
   *      enough bits of randomness to the function
   * @param rnd256 source of randomness – up to 256 bits of random data,
   *      can be generated by `generate256` function
   * @param b number of bits to use in rnd256, zero means use all 256 bits
   * @param n number of possible output values, upper bound is `n - 1`
   * @return a random value in range [0, n), quadratic distribution
   */
  function quadratic(uint256 rnd256, uint8 b, uint256 n) internal pure returns (uint256) {
    // we split provided randomness into two halves based on the `b`

    // calculate the mask based on number of bits (`b/2`)
    // if b is zero its same as 256, which is full mask
    uint128 mask = b == 0? uint128(-1): (uint128(1) << b / 2) - 1; // uint128(-1) overflows to 0xFFFF...

    // extract first uniformly distributed random using half of the bits
    uint128 p1 = uint128(rnd256 & mask);

    // extract second uniformly distributed random using half of the bits
    uint128 p2 = uint128(rnd256 >> b / 2 & mask);

    // feed multiplication of two uniforms into uniform to get quadratic
    return uniform(p1 * p2, b, n);
  }

  /**
   * @dev Generates random value based on keccak256 hash of
   *      * seed
   *      * block.difficulty,
   *      * block.number,
   *      * gasleft(),
   *      * msg.data,
   *      * msg.sender,
   *      * msg.value,
   *      * tx.gasprice,
   *      * tx.origin
   * @dev The random value generated is not cryptographically secure
   *      and may be heavily influenced by miners, but its cheap though
   * @param seed a number to be added as a parameter to keccak256,
   *      can be zero (zero can be used as some default value)
   * @return random value – all possible values of uint256
   */
  function generate256(uint256 seed) internal view returns (uint256 rnd256) {
    // build the keccak256 hash of the transaction dependent values
    bytes32 hash = keccak256(abi.encodePacked(
      seed,
      block.difficulty,
      block.number,
      gasleft(),
      msg.data,
      msg.sender,
      msg.value,
      tx.gasprice,
      tx.origin
    ));
    // and return the result
    return uint256(hash);
  }
}
