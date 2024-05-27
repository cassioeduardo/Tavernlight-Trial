void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
  Player playerData(nullptr); //Replaced the heap allocation "new Player(nullptr)" with a stack allocation. Also eliminates the need for a deallocation call.
  Player* playerPtr = g_game.getPlayerByName(recipient); //Renamed "player" to "playerPtr".
  
  if (!playerPtr) {
    if (!IOLoginData::loadPlayerByName(&playerData, recipient)) { //Pass the address of "playerData" to "loadPlayerByName".
      return;
    }

    playerPtr = &playerData; //Assign the loaded data to the pointer.
  }

  //From this point on I just replaced "player" with "playerPtr".
  Item* item = Item::CreateItem(itemId);
  if (!item) {
    return;
  }

  g_game.internalAddItem(playerPtr->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT);

  if (playerPtr->isOffline()) {
    IOLoginData::savePlayer(playerPtr);
  }
}
