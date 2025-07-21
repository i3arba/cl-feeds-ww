// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

// Chimera deps
import {BaseSetup} from "@chimera/BaseSetup.sol";
import {vm} from "@chimera/Hevm.sol";

// Managers
import {ActorManager} from "@recon/ActorManager.sol";
import {AssetManager} from "@recon/AssetManager.sol";

// Helpers
import {Utils} from "@recon/Utils.sol";

// Your deps
import "src/CLFExample.sol";

// Mocks
import { MockV3Aggregator } from "@cl/src/data-feeds/MockV3Aggregator.sol";

abstract contract Setup is BaseSetup, ActorManager, AssetManager, Utils {
    CLFExample cLFExample;
    
    /// === Setup === ///
    /// This contains all calls to be performed in the tester constructor, both for Echidna and Foundry
    function setup() internal virtual override {
        cLFExample = new CLFExample(
            address(new MockV3Aggregator(8, 20e8)), // feeds
            address(this), // owner
            _getActor() // Actor address
        );
    }

    /// === MODIFIERS === ///
    /// Prank admin and actor
    
    modifier asAdmin {
        vm.prank(address(this));
        _;
    }

    modifier asActor {
        vm.prank(address(_getActor()));
        _;
    }
}
