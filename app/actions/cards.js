
function hideCard(id) {
  return {
    type: 'HIDE_CARD',
    id: id
  }
}

module.exports = {
  hideCard
};
