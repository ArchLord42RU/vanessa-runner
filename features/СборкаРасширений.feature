# language: ru

Функционал: Сборка расширений конфигурации
    Как разработчик
    Я хочу иметь возможность собрать расширения конфигурации из исходников и подключить к нужной конфигурации
    Чтобы выполнять коллективную разработку проекта 1С

Контекст:
    Допустим я подготовил репозиторий и рабочий каталог проекта

    И Я копирую каталог "cfe" из каталога "tests/fixtures" проекта в рабочий каталог

Сценарий: Сборка одного расширения с временной базой
    
    Допустим каталог "epf" не существует
    Когда Я выполняю команду "oscript" c параметрами "<КаталогПроекта>/src/main.os compileext cfe РасширениеНовое1"
    Тогда Я сообщаю вывод команды "oscript"
    Тогда Код возврата команды "oscript" равен 0
  
    Тогда Вывод команды "oscript" содержит
    """
        Список расширений конфигурации:
        РасширениеНовое1    
    """

# TODO Сценарий: Сборка одного расширения с явно заданной базой
# TODO Сценарий: Сборка каталога расширений с явно заданной базой
# TODO Сценарий: Сборка каталога расширений с временной базой
