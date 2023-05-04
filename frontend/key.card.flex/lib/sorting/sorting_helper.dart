import '../realm/schemas.dart';

class SortingHelper{
  static List<Task> sortTaskByDeadline(List<Task> tasks, bool asc){
    return quickSortTaskByDate(tasks, 0, tasks.length - 1, asc, true);
  }

  static List<Task> sortTaskByCreationDate(List<Task> tasks, bool asc){
    return quickSortTaskByDate(tasks, 0, tasks.length - 1, asc, false);
  }

  static List<Task> quickSortTaskByDate(List<Task> tasks, int low, int high, bool asc, bool deadline){
    if(low < high){
      int pi;
      if(deadline){
        pi = _partitionTasksByDeadline(tasks, low, high, asc);
      } else{
        pi = _partitionTasksByCreationDate(tasks, low, high, asc);
      }

      quickSortTaskByDate(tasks, low, pi - 1, asc ,deadline);
      quickSortTaskByDate(tasks, pi + 1, high, asc, deadline);
    }
    return tasks;
  }

  static int _partitionTasksByDeadline(List<Task> values, int low, int high, bool asc){
    if (values.isEmpty) {
      return 0;
    }

    Task pivot = values[high];

    int i = low - 1;

    for(int j = low; j <= high - 1; j++){
      if(asc){
        if(!pivot.hasDeadline){
          i++;
          swap(values, i, j);
        }
        else if(pivot.hasDeadline && values[j].hasDeadline && values[j].deadline!.millisecondsSinceEpoch > pivot.deadline!.millisecondsSinceEpoch){
          i++;
          swap(values, i, j);
        }
      }else{
        if(!pivot.hasDeadline){
          i++;
          swap(values, i, j);
        }
        else if(pivot.hasDeadline && values[j].hasDeadline && values[j].deadline!.millisecondsSinceEpoch < pivot.deadline!.millisecondsSinceEpoch){
          i++;
          swap(values, i, j);
        }
      }
    }
    swap(values, i + 1, high);
    return i + 1;
  }

  static int _partitionTasksByCreationDate(List<Task> values, int low, int high, bool asc){
    if (values.isEmpty) {
      return 0;
    }

    Task pivot = values[high];

    int i = low - 1;

    for(int j = low; j <= high - 1; j++){
      if(asc){
        if(values[j].creationDate.millisecondsSinceEpoch > pivot.creationDate.millisecondsSinceEpoch){
          i++;
          swap(values, i, j);
        }
      }else{
        if(values[j].creationDate.millisecondsSinceEpoch < pivot.creationDate.millisecondsSinceEpoch){
          i++;
          swap(values, i, j);
        }
      }
    }
    swap(values, i + 1, high);
    return i + 1;
  }

  static void swap(List<dynamic> values, int v1, int v2){
      dynamic temp = values[v1];
      values[v1] = values[v2];
      values[v2] = temp;
  }
}