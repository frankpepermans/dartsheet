part of dartsheet.model;

class Selector {
  
  List<String> fromCellSelector(String value, Cell getCell(int row, int col), { bool forClick: false }) {
    final List<String> cellIds = <String>[];
    final List<String> pairs = value.split(',');
    
    if (pairs.length % 2 == 0) for (int i=0, len=pairs.length; i<len; i+=2) {
      final String cols = pairs[i].trim(), rows = pairs[i + 1].trim();
      final List<String> colRange = cols.split(':'), rowRange = rows.split(':');
      final int minColNumber = colRange.first.trim().toUpperCase().codeUnitAt(0);
      final int maxColNumber = colRange.last.trim().toUpperCase().codeUnitAt(0);
      final int minRowNumber = int.parse(rowRange.first.trim());
      final int maxRowNumber = int.parse(rowRange.last.trim());
      
      for (int j=minColNumber + 1, len2=maxColNumber-minColNumber+65; j<=len2; j++)
        colRange.add(new String.fromCharCode(j));
      
      for (int j=minRowNumber + 1, len2=maxRowNumber-minRowNumber; j<=len2; j++)
        rowRange.add(j.toString());
      
      colRange.forEach((String col) {
        final int colNumber = col.trim().toUpperCase().codeUnitAt(0) - 65;
        
        rowRange.forEach((String row) {
          final int rowNumber = int.parse(row.trim()) - 1;
          final Cell cell = getCell(rowNumber, colNumber);
          
          if (cell != null) {
            (forClick) ? cellIds.add('${cell.id}_click') : cellIds.add(cell.id);
                      
            cell.toRxStreams();
          }
        });
      });
    }
    
    return cellIds;
  }
  
  String transformCellSelector(String value, int rowOffset, int colOffset) {
    final List<String> newPairs = <String>[];
    final List<String> pairs = value.split(',');
    
    if (pairs.length % 2 == 0) for (int i=0, len=pairs.length; i<len; i+=2) {
      final String cols = pairs[i].trim();
      final String rows = pairs[i + 1].trim();
      final List<String> colRange = cols.split(':'), rowRange = rows.split(':');
      final List<String> newColRange = <String>[], newRowRange = <String>[];
      
      colRange.forEach((String col) {
        final String exactCol = col.trim().toUpperCase();
        
        if (exactCol.isNotEmpty) newColRange.add(toColIdentity(exactCol.codeUnitAt(0) - 65 + colOffset));
        else newColRange.add('*');
      });
      
      rowRange.forEach((String row) =>
        newRowRange.add((int.parse(row.trim(), onError: (_) => -1) + rowOffset).toString())
      );
      
      newPairs.add(newColRange.join(':'));
      newPairs.add(newRowRange.join(':'));
    }
    
    return newPairs.join(', ');
  }
  
}