// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./dummyRoundImplementation.sol";
import "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../../utils/MetaPtr.sol";


/**
 * @notice Invoked by a RoundOperator to enable creation of a
 * round by cloning the RoundImplementation contract.
 * The factory contract emits an event anytime a round is created
 * which can be used to derive the round registry.
 *
 * @dev RoundFactory is deployed once per chain and stores
 * a reference to the deployed RoundImplementation.
 * @dev RoundFactory uses openzeppelin Clones to reduce deploy
 * costs and also allows uprgrading RoundContract
 * @dev This contract is Ownable thus supports ownership transfership
 *
 */
contract DummyRoundFactory is OwnableUpgradeable {

  address public RoundContract;

  string public foobar;

  // --- Event ---

  /// @notice Emitted when a Round contract is updated
  event RoundContractUpdated(address roundAddress);

  /// @notice Emitted when a new Round is created
  event RoundCreated(address indexed roundAddress, address indexed ownedBy);


  /// @notice constructor function which ensure deployer is set as owner
  function initialize() public initializer {
    __Context_init_unchained();
    __Ownable_init_unchained();
  }

  // --- Core methods ---

  /**
   * @notice Allows the owner to update the RoundImplementation.
   * This provides us the flexibility to upgrade RoundImplementation
   * contract while relying on the same RoundFactory to get the list of
   * rounds.
   */
  function updateRoundContract(address _RoundContract) public onlyOwner {
    RoundContract = _RoundContract;

    emit RoundContractUpdated(_RoundContract);
  }

  /**
   * @notice Clones RoundImp a new round and emits event
   *
   * @param _encodedParameters Encoded parameters for creating a round
   * @param _ownedBy Program which created the contract
   */
  function create(
    bytes calldata _encodedParameters,
    address _ownedBy,
    string calldata _foobar
  ) external returns (address) {

    foobar = _foobar;
    address _clone = ClonesUpgradeable.clone(RoundContract);

    DummyRoundImplementation(_clone).initialize(
      _encodedParameters,
      _foobar
    );

    emit RoundCreated(_clone, _ownedBy);

    return _clone;
  }

}