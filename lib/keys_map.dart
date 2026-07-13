class KeyMap {
  bool left; // Guarda estado 'true' se a tecla para a esquerda estiver ativada.
  bool right; // Guarda estado 'true' se a tecla para a direita estiver ativada.

  KeyMap({
    this.left = false, // Inicialmente, o movimento para a esquerda está inativo.
    this.right = false, // Inicialmente, o movimento para a direita está inativo.
  });
}