public void spiralPrint(int[][] matrix) {
	int startRow = 0;
	int endRow = matrix.length;
	int startCol = 0;
	int endCol = matrix[0].length;

	while (startRow < endRow && startCol < endCol) {
		// Top row
		for (int i = startCol; i < endCol; i++) {
			System.out.print(matrix[startRow][i] + " ");
		}
		startRow++;

		// Righ col
		for (int i = startRow; i < endRow; i++) {
			System.out.print(matrix[i][endCol - 1] + " ");
		}
		endCol--;

		// Bottom row
		if (startRow < endRow) {
			for (int i = endCol - 1; i >= startCol; i--) {
				System.out.print(matrix[endRow - 1][i] + " ");
			}
			endRow--;
		}

		// Left col
		if (startCol < endCol) {
			for (int i = endRow - 1; i >= startRow; i--) {
				System.out.print(matrix[i][startCol] + " ");
			}
			startCol++;
		}

	} // End of while loop

}