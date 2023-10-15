import '../app/data/models/schemas.dart';

class SortingHelper{
  static int compareCards(KeyValueCard c1,KeyValueCard c2) {
    int result = c1.currentBox.compareTo(c2.currentBox);
    if(result == 0) {
      return c1.seenCount.compareTo(c2.seenCount);
    }
    return result;
  }

  static List<Task> sortTaskByDeadline(List<Task> tasks, bool asc){
    return quickSortTaskByDate(tasks, 0, tasks.length - 1, asc, 0);
  }

  static List<Task> sortTaskByCreationDate(List<Task> tasks, bool asc){
    return quickSortTaskByDate(tasks, 0, tasks.length - 1, asc, 1);
  }

  static List<Task> sortTaskByReminderDate(List<Task> tasks, bool asc){
    return quickSortTaskByDate(tasks, 0, tasks.length - 1, asc, 2);
  }

  static List<Task> quickSortTaskByDate(List<Task> tasks, int low, int high, bool asc, int field){
    if(low < high){
      int pi;

      if(field == 0){
        pi = _partitionTasksByDeadline(tasks, low, high, asc);
      } else if(field == 1){ // creation date
        pi = _partitionTasksByCreationDate(tasks, low, high, asc);
      } else {
        pi = _partitionTasksByReminderDate(tasks, low, high, asc);
      }

      quickSortTaskByDate(tasks, low, pi - 1, asc , field);
      quickSortTaskByDate(tasks, pi + 1, high, asc, field);
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
      if(!pivot.hasDeadline || pivot.isComplete) { // place the completed and without deadline tasks at the end
        if(values[j].hasDeadline && values[j].isComplete && pivot.hasDeadline){ // if they have a deadline but are completed, still sort them
          if(asc && values[j].deadline!.millisecondsSinceEpoch > pivot.deadline!.millisecondsSinceEpoch){ // asc
            i++;
            swap(values, i, j);
          } else if(!asc && values[j].deadline!.millisecondsSinceEpoch < pivot.deadline!.millisecondsSinceEpoch){ // desc
            i++;
            swap(values, i, j);
          }
        } else {
          i++;
          swap(values, i, j);
        }
      } else if (values[j].hasDeadline && !values[j].isComplete) { // if they both have a deadline and are not completed
        if(asc && values[j].deadline!.millisecondsSinceEpoch > pivot.deadline!.millisecondsSinceEpoch){ // asc
          i++;
          swap(values, i, j);
        } else if(!asc && values[j].deadline!.millisecondsSinceEpoch < pivot.deadline!.millisecondsSinceEpoch){ // desc
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

  static int _partitionTasksByReminderDate(List<Task> values, int low, int high, bool asc) {
    if (values.isEmpty) {
      return 0;
    }

    Task pivot = values[high];

    int i = low - 1;

    for(int j = low; j <= high - 1; j++){
      if(pivot.hasReminder && values[j].hasReminder) { // place the tasks without reminder at the end
          if(asc && values[j].reminder!.millisecondsSinceEpoch > pivot.reminder!.millisecondsSinceEpoch){ // asc
            i++;
            swap(values, i, j);
          } else if(!asc && values[j].reminder!.millisecondsSinceEpoch < pivot.reminder!.millisecondsSinceEpoch){ // desc
            i++;
            swap(values, i, j);
          }
      } else if(!pivot.hasReminder){
        i++;
        swap(values, i, j);
      }
    }
    swap(values, i + 1, high);
    return i + 1;
  }
}
