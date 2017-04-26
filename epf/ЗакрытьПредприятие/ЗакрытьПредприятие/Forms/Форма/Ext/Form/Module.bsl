﻿&НаКлиенте
Перем СчетчикОжиданияРезультатов;

&НаКлиенте
Перем МаксИтерацийОжиданияРезультатов;

&НаКлиенте
Перем ИндикаторВыполнения;

&НаКлиенте
Перем ФормаОбновленияНайденаОдинРаз;

&НаКлиенте
Перем ФормаНачальногоЗаполненияНайденаОдинРаз;

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	Попытка
		Выполнить("ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(""ОбщиеНастройкиПользователя"", 
			|""ЗапрашиватьПодтверждениеПриЗавершенииПрограммы"", Ложь);");
	Исключение
		// Данного модуля и метода может не быть в конфигурации
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если Не ЭтоКонфигурацияНаБазеБСПСервер() Тогда
		ЗавершитьРаботуСистемы(Ложь, Ложь);
		//Сообщить("Заглушка - завершаем работу системы");
		Возврат;
	КонецЕсли; 
	
	ПодключитьОбработчикОжидания("ПроверитьНеобходимостьЗавершенияПрограммы", 10, Истина);
	ПодключитьОбработчикОжидания("ПроверитьЛегальностьОбновления", 2);
	
КонецПроцедуры

&НаКлиенте 
Процедура ПроверитьНеобходимостьЗавершенияПрограммы() Экспорт
	Перем НеобходимоОжидание, МожноЗавершатьРаботу;
	
	НеобходимоОжидание = (Найти(ПараметрЗапуска, "ЗавершитьРаботуСистемы") > 0);
	МожноЗавершатьРаботу = Ложь;
	//СтрокаОшибкиОбновления = Нрег("Не выполнены дополнительные процедуры обработки данных");
	СтрокаНеудачиОбновления = Нрег("Не удалось выполнить обновление");
	
	ФормаОбновленияНайдена = Ложь;
	РезультатОбновленияНайден = Ложь;
	ФормаНачальногоЗаполненияНайдена = Ложь;
	
	Окна = ПолучитьОкна();
	Для каждого Окн Из Окна Цикл
		Если ТипЗнч(Окн) = Тип("ОкноКлиентскогоПриложения") Тогда
			
			Содержимое = Окн.ПолучитьСодержимое();
			
			ОбновитьПрогресс = Ложь;
			Если Найти(НРег(Строка(Окн.Заголовок)), "обновление версии")>0 Тогда
				ФормаОбновленияНайденаОдинРаз = Истина;
				ФормаОбновленияНайдена = Истина;
				ОбновитьПрогресс = Истина;
				
			ИначеЕсли Найти(НРег(Строка(Окн.Заголовок)), "начальное заполнение")>0 Тогда
				ФормаНачальногоЗаполненияНайденаОдинРаз = Истина;
				ФормаНачальногоЗаполненияНайдена = Истина;
				ОбновитьПрогресс = Истина;
			КонецЕсли;
			
			Если ОбновитьПрогресс Тогда
				
				СчетчикОжиданияРезультатов = 1;
				ПроцентВыполнения = 0;
				Попытка
					Если ТипЗнч(Содержимое) = Тип("УправляемаяФорма") Тогда
						ПроцентВыполнения = Содержимое.ПрогрессВыполнения;
					КонецЕсли; 
				Исключение
				    Сообщить(ОписаниеОшибки());
				КонецПопытки; 
				
				Если ПроцентВыполнения <> ИндикаторВыполнения Тогда
					ИндикаторВыполнения = ПроцентВыполнения;
					СтрокаСообщения = ""+ТекущаяДата() + " - " + ПроцентВыполнения + "% Нашли форму обновления подождем еще";
					Сообщить(СтрокаСообщения);
				КонецЕсли; 
				
			КонецЕсли;
			
			Если СчетчикОжиданияРезультатов > 0 И Найти(НРег(Строка(Окн.Заголовок)), "что нового в конфигурации")>0 Тогда
				СчетчикОжиданияРезультатов = МаксИтерацийОжиданияРезультатов + 1;
				Сообщить(""+ТекущаяДата() + " - Удачное завершение обновления");
				МожноЗавершатьРаботу = Истина;
				Прервать;
			КонецЕсли;
			
			Если Найти(НРег(Строка(Окн.Заголовок)), СтрокаНеудачиОбновления)>0 Тогда 
			    СчетчикОжиданияРезультатов = МаксИтерацийОжиданияРезультатов + 1;
				МожноЗавершатьРаботу = Истина;
				
				Попытка
					Если ТипЗнч(Содержимое) = Тип("УправляемаяФорма") Тогда
						ТекстОшибки = Содержимое.Элементы.ТекстСообщенияОбОшибке.Заголовок;
						Сообщить("ERROR: "+ТекущаяДата() + " "+ТекстОшибки);
					КонецЕсли; 
					
				Исключение
				 	Сообщить("ERROR: "+ТекущаяДата() + ОписаниеОшибки());   
				КонецПопытки; 
				
				Сообщить("ERROR: "+ТекущаяДата() + "Неудачное обновление конфигурации");
				Если Не Содержимое = Неопределено И ТипЗнч(Содержимое) = Тип("УправляемаяФорма") Тогда
					Содержимое.Закрыть();
				КонецЕсли;
				
				Прервать;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Если НеобходимоОжидание И МожноЗавершатьРаботу = Ложь И СчетчикОжиданияРезультатов <= МаксИтерацийОжиданияРезультатов Тогда
		СчетчикОжиданияРезультатов = СчетчикОжиданияРезультатов + 1;
		ПодключитьОбработчикОжидания("ПроверитьНеобходимостьЗавершенияПрограммы", 10, Истина);
	КонецЕсли; 
			
	Если ФормаОбновленияНайдена = Ложь И ФормаОбновленияНайденаОдинРаз = Истина Тогда
		СчетчикОжиданияРезультатов = МаксИтерацийОжиданияРезультатов + 1;		
	КонецЕсли; 
			
	Если ФормаНачальногоЗаполненияНайдена = Ложь И ФормаНачальногоЗаполненияНайденаОдинРаз = Истина Тогда
		СчетчикОжиданияРезультатов = МаксИтерацийОжиданияРезультатов + 1;		
	КонецЕсли; 
	
	Если СчетчикОжиданияРезультатов > МаксИтерацийОжиданияРезультатов И НеобходимоОжидание = Истина Тогда
		Сообщить(""+ТекущаяДата() + " - "+"Завершаем работу");
		
		Если Не Содержимое = Неопределено И ТипЗнч(Содержимое) = Тип("УправляемаяФорма") Тогда
			//Содержимое.Закрыть();
		КонецЕсли;
		
		ПодключитьОбработчикОжидания("ЗавершитьРаботу", 1, Истина);
		
		
	КонецЕсли; 
	
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ЗаписатьПодтверждениеЛегальностиПолученияОбновлений()
	
	УстановитьПривилегированныйРежим(Истина);
	Выполнить("ОбновлениеИнформационнойБазыСлужебный.ЗаписатьПодтверждениеЛегальностиПолученияОбновлений();");
		
КонецПроцедуры
 
&НаКлиенте 
Процедура ПроверитьЛегальностьОбновления() Экспорт
	
	Окна = ПолучитьОкна();
	Для каждого Окн Из Окна Цикл
		Если ТипЗнч(Окн) = Тип("ОкноКлиентскогоПриложения") Тогда
			Содержимое = Окн.ПолучитьСодержимое();
			Если Найти(НРег(Строка(Окн.Заголовок)), "легальност") > 0 Тогда
				Попытка
					Если ТипЗнч(Содержимое) = Тип("УправляемаяФорма") Тогда
						Содержимое.Результат = Истина;  
						Содержимое.Закрыть(Истина);
						ЗаписатьПодтверждениеЛегальностиПолученияОбновлений();
						СчетчикОжиданияРезультатов = 0;
					КонецЕсли; 
				Исключение
				    Сообщить(ОписаниеОшибки());
				КонецПопытки;
				
				ОтключитьОбработчикОжидания("ПроверитьЛегальностьОбновления");
				
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
				
КонецПроцедуры
	
&НаКлиенте
Процедура ЗавершитьРаботу() Экспорт 
	ЗавершитьРаботуСистемы(Истина);
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЭтоКонфигурацияНаБазеБСПСервер()
	Рез = Ложь;
	Описание = Новый Структура;
	Попытка
		Выполнить("ОбновлениеИнформационнойБазыБСП.ПриДобавленииПодсистемы(Описание);");
		Рез = Описание.Имя = "СтандартныеПодсистемы";
	Исключение
		ИнфоОшибки = ИнформацияОбОшибке();
		//Сообщить("Описание = '" + ИнфоОшибки.Описание + "'", СтатусСообщения.Внимание);
		//Сообщить("Модуль = '" + ИнфоОшибки.ИмяМодуля + "'", СтатусСообщения.Важное);
		//Сообщить("НомерСтроки = '" + ИнфоОшибки.НомерСтроки + "'", СтатусСообщения.Важное);
		//Сообщить("ИсходнаяСтрока = '" + ИнфоОшибки.ИсходнаяСтрока + "'", СтатусСообщения.Важное); 
		Рез = НРег(ИнфоОшибки.ИмяМодуля) = НРег("ОбщийМодуль.ОбновлениеИнформационнойБазыБСП.Модуль");
	КонецПопытки;
	Возврат Рез;
КонецФункции

 
СчетчикОжиданияРезультатов = 0;
МаксИтерацийОжиданияРезультатов = 5;
ИндикаторВыполнения = 0;
ФормаОбновленияНайденаОдинРаз = Ложь;
ФормаНачальногоЗаполненияНайденаОдинРаз = Ложь;