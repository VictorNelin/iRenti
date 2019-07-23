

const Map kLines = {
  1: {
    'line': 'Сокольническая линия',
    'color': 15668766,
  },
  2: {
    'line': 'Замоскворецкая линия',
    'color': 2997804,
  },
  3: {
    'line': 'Арбатско-Покровская линия',
    'color': 30910,
  },
  4: {
    'line': 'Филёвская линия',
    'color': 49151,
  },
  5: {
    'line': 'Кольцевая линия',
    'color': 9263917,
  },
  6: {
    'line': 'Калужско-Рижская линия',
    'color': 15569185,
  },
  7: {
    'line': 'Таганско-Краснопресненская линия',
    'color': 8388736,
  },
  8: {
    'line': 'Калининская линия',
    'color': 16766722,
  },
  9: {
    'line': 'Серпуховско-Тимирязевская линия',
    'color': 10066329,
  },
  10: {
    'line': 'Люблинско-Дмитровская линия',
    'color': 10079232,
  },
  11: {
    'line': 'Каховская линия',
    'color': 8569024,
  },
  12: {
    'line': 'Бутовская линия Лёгкого метро',
    'color': 10597332,
  },
  13: {
    'line': 'Московская монорельсовая транспортная система',
    'color': 10066431,
  },
  14: {
    'line': 'Солнцевская линия',
    'color': 16766722,
  },
  15: {
    'line': 'Некрасовская линия',
    'color': 14574753,
  },
  16: {
    'line': 'Большая кольцевая линия',
    'color': 8569024,
  },
  17: {
    'line': 'Московское центральное кольцо',
    'color': 16777215,
  }
};

const List kStations = [
  {
    'active': true,
    'title': 'Авиамоторная',
    'line': 8,
    'id': 133
  },
  {
    'active': false,
    'title': 'Авиамоторная',
    'line': 15,
    'id': 230
  },
  {
    'active': false,
    'title': 'Авиамоторная',
    'line': 16,
    'id': 257
  },
  {
    'active': true,
    'title': 'Автозаводская',
    'line': 2,
    'id': 27
  },
  {
    'active': true,
    'title': 'Автозаводская',
    'line': 17,
    'id': 292
  },
  {
    'active': true,
    'title': 'Академическая',
    'line': 6,
    'id': 101
  },
  {
    'active': true,
    'title': 'Александровский сад',
    'line': 4,
    'id': 71
  },
  {
    'active': true,
    'title': 'Алексеевская',
    'line': 6,
    'id': 91
  },
  {
    'active': true,
    'title': 'Алма-Атинская',
    'line': 2,
    'id': 196
  },
  {
    'active': true,
    'title': 'Алтуфьево',
    'line': 9,
    'id': 137
  },
  {
    'active': false,
    'title': 'Аминьевское шоссе',
    'line': 16,
    'id': 245
  },
  {
    'active': true,
    'title': 'Андроновка',
    'line': 17,
    'id': 270
  },
  {
    'active': true,
    'title': 'Аннино',
    'line': 9,
    'id': 160
  },
  {
    'active': true,
    'title': 'Арбатская',
    'line': 3,
    'id': 49
  },
  {
    'active': true,
    'title': 'Арбатская',
    'line': 4,
    'id': 70
  },
  {
    'active': true,
    'title': 'Аэропорт',
    'line': 2,
    'id': 35
  },
  {
    'active': true,
    'title': 'Бабушкинская',
    'line': 6,
    'id': 87
  },
  {
    'active': true,
    'title': 'Багратионовская',
    'line': 4,
    'id': 64
  },
  {
    'active': true,
    'title': 'Балтийская',
    'line': 17,
    'id': 281
  },
  {
    'active': true,
    'title': 'Баррикадная',
    'line': 7,
    'id': 118
  },
  {
    'active': true,
    'title': 'Бауманская',
    'line': 3,
    'id': 46
  },
  {
    'active': true,
    'title': 'Беговая',
    'line': 7,
    'id': 116
  },
  {
    'active': true,
    'title': 'Белокаменная',
    'line': 17,
    'id': 275
  },
  {
    'active': true,
    'title': 'Беломорская',
    'line': 2,
    'id': 303
  },
  {
    'active': true,
    'title': 'Белорусская',
    'line': 2,
    'id': 33
  },
  {
    'active': true,
    'title': 'Белорусская',
    'line': 5,
    'id': 83
  },
  {
    'active': true,
    'title': 'Беляево',
    'line': 6,
    'id': 105
  },
  {
    'active': true,
    'title': 'Бибирево',
    'line': 9,
    'id': 138
  },
  {
    'active': true,
    'title': 'Библиотека имени Ленина',
    'line': 1,
    'id': 11
  },
  {
    'active': true,
    'title': 'Битцевский парк',
    'line': 12,
    'id': 215
  },
  {
    'active': true,
    'title': 'Борисово',
    'line': 10,
    'id': 176
  },
  {
    'active': true,
    'title': 'Боровицкая',
    'line': 9,
    'id': 148
  },
  {
    'active': true,
    'title': 'Боровское шоссе',
    'line': 14,
    'id': 267
  },
  {
    'active': true,
    'title': 'Ботанический сад',
    'line': 6,
    'id': 89
  },
  {
    'active': true,
    'title': 'Ботанический сад',
    'line': 17,
    'id': 277
  },
  {
    'active': true,
    'title': 'Братиславская',
    'line': 10,
    'id': 174
  },
  {
    'active': true,
    'title': 'Бульвар Дмитрия Донского',
    'line': 9,
    'id': 161
  },
  {
    'active': true,
    'title': 'Бульвар Рокоссовского',
    'line': 1,
    'id': 1
  },
  {
    'active': true,
    'title': 'Бульвар Рокоссовского',
    'line': 17,
    'id': 274
  },
  {
    'active': true,
    'title': 'Бульвар адмирала Ушакова',
    'line': 12,
    'id': 184
  },
  {
    'active': true,
    'title': 'Бунинская аллея',
    'line': 12,
    'id': 186
  },
  {
    'active': true,
    'title': 'Бутырская',
    'line': 10,
    'id': 207
  },
  {
    'active': true,
    'title': 'ВДНХ',
    'line': 6,
    'id': 90
  },
  {
    'active': true,
    'title': 'Варшавская',
    'line': 11,
    'id': 180
  },
  {
    'active': true,
    'title': 'Верхние Котлы',
    'line': 17,
    'id': 290
  },
  {
    'active': true,
    'title': 'Верхние Лихоборы',
    'line': 10,
    'id': 211
  },
  {
    'active': true,
    'title': 'Владыкино',
    'line': 9,
    'id': 140
  },
  {
    'active': true,
    'title': 'Владыкино',
    'line': 17,
    'id': 278
  },
  {
    'active': true,
    'title': 'Водный стадион',
    'line': 2,
    'id': 38
  },
  {
    'active': true,
    'title': 'Войковская',
    'line': 2,
    'id': 37
  },
  {
    'active': true,
    'title': 'Волгоградский проспект',
    'line': 7,
    'id': 124
  },
  {
    'active': true,
    'title': 'Волжская',
    'line': 10,
    'id': 172
  },
  {
    'active': true,
    'title': 'Волоколамская',
    'line': 3,
    'id': 59
  },
  {
    'active': false,
    'title': 'Волхонка',
    'line': 14,
    'id': 219
  },
  {
    'active': true,
    'title': 'Воробьёвы горы',
    'line': 1,
    'id': 16
  },
  {
    'active': false,
    'title': 'Воронцовская',
    'line': 16,
    'id': 249
  },
  {
    'active': true,
    'title': 'Выставочная',
    'line': 4,
    'id': 72
  },
  {
    'active': true,
    'title': 'Выставочный центр',
    'line': 13,
    'id': 188
  },
  {
    'active': true,
    'title': 'Выхино',
    'line': 7,
    'id': 128
  },
  {
    'active': true,
    'title': 'Говорово',
    'line': 14,
    'id': 302
  },
  {
    'active': true,
    'title': 'Деловой центр',
    'line': 14,
    'id': 217
  },
  {
    'active': false,
    'title': 'Деловой центр',
    'line': 16,
    'id': 240
  },
  {
    'active': true,
    'title': 'Деловой центр',
    'line': 17,
    'id': 285
  },
  {
    'active': true,
    'title': 'Динамо',
    'line': 2,
    'id': 34
  },
  {
    'active': true,
    'title': 'Дмитровская',
    'line': 9,
    'id': 143
  },
  {
    'active': false,
    'title': 'Дмитровское шоссе',
    'line': 10,
    'id': 214
  },
  {
    'active': true,
    'title': 'Добрынинская',
    'line': 5,
    'id': 76
  },
  {
    'active': true,
    'title': 'Домодедовская',
    'line': 2,
    'id': 21
  },
  {
    'active': false,
    'title': 'Дорогомиловская',
    'line': 14,
    'id': 220
  },
  {
    'active': true,
    'title': 'Достоевская',
    'line': 10,
    'id': 163
  },
  {
    'active': true,
    'title': 'Дубровка',
    'line': 10,
    'id': 169
  },
  {
    'active': true,
    'title': 'Дубровка',
    'line': 17,
    'id': 297
  },
  {
    'active': true,
    'title': 'Жулебино',
    'line': 7,
    'id': 205
  },
  {
    'active': true,
    'title': 'ЗИЛ',
    'line': 17,
    'id': 291
  },
  {
    'active': true,
    'title': 'Зорге',
    'line': 17,
    'id': 304
  },
  {
    'active': true,
    'title': 'Зябликово',
    'line': 10,
    'id': 178
  },
  {
    'active': true,
    'title': 'Измайлово',
    'line': 17,
    'id': 272
  },
  {
    'active': true,
    'title': 'Измайловская',
    'line': 3,
    'id': 42
  },
  {
    'active': true,
    'title': 'Калужская',
    'line': 6,
    'id': 104
  },
  {
    'active': true,
    'title': 'Кантемировская',
    'line': 2,
    'id': 24
  },
  {
    'active': true,
    'title': 'Каховская',
    'line': 11,
    'id': 181
  },
  {
    'active': false,
    'title': 'Каховская',
    'line': 16,
    'id': 251
  },
  {
    'active': true,
    'title': 'Каширская',
    'line': 2,
    'id': 25
  },
  {
    'active': true,
    'title': 'Каширская',
    'line': 11,
    'id': 179
  },
  {
    'active': false,
    'title': 'Каширская',
    'line': 16,
    'id': 252
  },
  {
    'active': true,
    'title': 'Киевская',
    'line': 3,
    'id': 51
  },
  {
    'active': true,
    'title': 'Киевская',
    'line': 4,
    'id': 68
  },
  {
    'active': true,
    'title': 'Киевская',
    'line': 5,
    'id': 85
  },
  {
    'active': true,
    'title': 'Китай-город',
    'line': 6,
    'id': 96
  },
  {
    'active': true,
    'title': 'Китай-город',
    'line': 7,
    'id': 121
  },
  {
    'active': true,
    'title': 'Кожуховская',
    'line': 10,
    'id': 170
  },
  {
    'active': true,
    'title': 'Коломенская',
    'line': 2,
    'id': 26
  },
  {
    'active': true,
    'title': 'Коммунарка',
    'line': 1,
    'id': 311
  },
  {
    'active': true,
    'title': 'Комсомольская',
    'line': 1,
    'id': 6
  },
  {
    'active': true,
    'title': 'Комсомольская',
    'line': 5,
    'id': 80
  },
  {
    'active': true,
    'title': 'Коньково',
    'line': 6,
    'id': 106
  },
  {
    'active': true,
    'title': 'Коптево',
    'line': 17,
    'id': 306
  },
  {
    'active': true,
    'title': 'Косино',
    'line': 15,
    'id': 226
  },
  {
    'active': true,
    'title': 'Котельники',
    'line': 7,
    'id': 206
  },
  {
    'active': true,
    'title': 'Красногвардейская',
    'line': 2,
    'id': 20
  },
  {
    'active': true,
    'title': 'Краснопресненская',
    'line': 5,
    'id': 84
  },
  {
    'active': true,
    'title': 'Красносельская',
    'line': 1,
    'id': 5
  },
  {
    'active': true,
    'title': 'Красные ворота',
    'line': 1,
    'id': 7
  },
  {
    'active': true,
    'title': 'Крестьянская застава',
    'line': 10,
    'id': 168
  },
  {
    'active': true,
    'title': 'Кропоткинская',
    'line': 1,
    'id': 12
  },
  {
    'active': true,
    'title': 'Крылатское',
    'line': 3,
    'id': 56
  },
  {
    'active': true,
    'title': 'Крымская',
    'line': 17,
    'id': 289
  },
  {
    'active': true,
    'title': 'Кузнецкий мост',
    'line': 7,
    'id': 120
  },
  {
    'active': true,
    'title': 'Кузьминки',
    'line': 7,
    'id': 126
  },
  {
    'active': true,
    'title': 'Кунцевская',
    'line': 3,
    'id': 54
  },
  {
    'active': true,
    'title': 'Кунцевская',
    'line': 4,
    'id': 61
  },
  {
    'active': false,
    'title': 'Кунцевская',
    'line': 16,
    'id': 244
  },
  {
    'active': true,
    'title': 'Курская',
    'line': 3,
    'id': 47
  },
  {
    'active': true,
    'title': 'Курская',
    'line': 5,
    'id': 79
  },
  {
    'active': true,
    'title': 'Кутузовская',
    'line': 4,
    'id': 66
  },
  {
    'active': true,
    'title': 'Кутузовская',
    'line': 17,
    'id': 286
  },
  {
    'active': true,
    'title': 'Ленинский проспект',
    'line': 6,
    'id': 100
  },
  {
    'active': true,
    'title': 'Лермонтовский проспект',
    'line': 7,
    'id': 204
  },
  {
    'active': true,
    'title': 'Лесопарковая',
    'line': 12,
    'id': 216
  },
  {
    'active': false,
    'title': 'Лефортово',
    'line': 16,
    'id': 258
  },
  {
    'active': true,
    'title': 'Лихоборы',
    'line': 17,
    'id': 280
  },
  {
    'active': true,
    'title': 'Локомотив',
    'line': 17,
    'id': 273
  },
  {
    'active': true,
    'title': 'Ломоносовский проспект',
    'line': 14,
    'id': 224
  },
  {
    'active': true,
    'title': 'Лубянка',
    'line': 1,
    'id': 9
  },
  {
    'active': true,
    'title': 'Лужники',
    'line': 17,
    'id': 287
  },
  {
    'active': true,
    'title': 'Лухмановская',
    'line': 15,
    'id': 228
  },
  {
    'active': true,
    'title': 'Люблино',
    'line': 10,
    'id': 173
  },
  {
    'active': true,
    'title': 'Марксистская',
    'line': 8,
    'id': 135
  },
  {
    'active': true,
    'title': 'Марьина роща',
    'line': 10,
    'id': 162
  },
  {
    'active': true,
    'title': 'Марьино',
    'line': 10,
    'id': 175
  },
  {
    'active': true,
    'title': 'Маяковская',
    'line': 2,
    'id': 32
  },
  {
    'active': true,
    'title': 'Медведково',
    'line': 6,
    'id': 86
  },
  {
    'active': true,
    'title': 'Международная',
    'line': 4,
    'id': 73
  },
  {
    'active': true,
    'title': 'Менделеевская',
    'line': 9,
    'id': 145
  },
  {
    'active': true,
    'title': 'Минская',
    'line': 14,
    'id': 223
  },
  {
    'active': true,
    'title': 'Митино',
    'line': 3,
    'id': 60
  },
  {
    'active': true,
    'title': 'Мичуринский проспект',
    'line': 14,
    'id': 263
  },
  {
    'active': false,
    'title': 'Мичуринский проспект',
    'line': 16,
    'id': 246
  },
  {
    'active': false,
    'title': 'Мневники',
    'line': 16,
    'id': 242
  },
  {
    'active': true,
    'title': 'Молодёжная',
    'line': 3,
    'id': 55
  },
  {
    'active': true,
    'title': 'Мякинино',
    'line': 3,
    'id': 58
  },
  {
    'active': true,
    'title': 'Нагатинская',
    'line': 9,
    'id': 152
  },
  {
    'active': false,
    'title': 'Нагатинский затон',
    'line': 16,
    'id': 253
  },
  {
    'active': true,
    'title': 'Нагорная',
    'line': 9,
    'id': 153
  },
  {
    'active': true,
    'title': 'Нахимовский проспект',
    'line': 9,
    'id': 154
  },
  {
    'active': true,
    'title': 'Некрасовка',
    'line': 15,
    'id': 229
  },
  {
    'active': true,
    'title': 'Нижегородская',
    'line': 17,
    'id': 295
  },
  {
    'active': false,
    'title': 'Нижегородская улица',
    'line': 15,
    'id': 231
  },
  {
    'active': false,
    'title': 'Нижегородская улица',
    'line': 16,
    'id': 256
  },
  {
    'active': false,
    'title': 'Нижняя Масловка',
    'line': 16,
    'id': 235
  },
  {
    'active': true,
    'title': 'Новогиреево',
    'line': 8,
    'id': 130
  },
  {
    'active': true,
    'title': 'Новокосино',
    'line': 8,
    'id': 129
  },
  {
    'active': true,
    'title': 'Новокузнецкая',
    'line': 2,
    'id': 29
  },
  {
    'active': true,
    'title': 'Новопеределкино',
    'line': 14,
    'id': 268
  },
  {
    'active': true,
    'title': 'Новослободская',
    'line': 5,
    'id': 82
  },
  {
    'active': true,
    'title': 'Новохохловская',
    'line': 17,
    'id': 294
  },
  {
    'active': true,
    'title': 'Новоясеневская',
    'line': 6,
    'id': 109
  },
  {
    'active': true,
    'title': 'Новые Черёмушки',
    'line': 6,
    'id': 103
  },
  {
    'active': true,
    'title': 'Озерная',
    'line': 14,
    'id': 301
  },
  {
    'active': true,
    'title': 'Окружная',
    'line': 10,
    'id': 210
  },
  {
    'active': true,
    'title': 'Окружная',
    'line': 17,
    'id': 279
  },
  {
    'active': false,
    'title': 'Окская улица',
    'line': 15,
    'id': 233
  },
  {
    'active': true,
    'title': 'Октябрьская',
    'line': 5,
    'id': 75
  },
  {
    'active': true,
    'title': 'Октябрьская',
    'line': 6,
    'id': 98
  },
  {
    'active': true,
    'title': 'Октябрьское поле',
    'line': 7,
    'id': 114
  },
  {
    'active': true,
    'title': 'Ольховка',
    'line': 1,
    'id': 310
  },
  {
    'active': true,
    'title': 'Орехово',
    'line': 2,
    'id': 22
  },
  {
    'active': true,
    'title': 'Отрадное',
    'line': 9,
    'id': 139
  },
  {
    'active': true,
    'title': 'Охотный ряд',
    'line': 1,
    'id': 10
  },
  {
    'active': false,
    'title': 'Очаково',
    'line': 14,
    'id': 264
  },
  {
    'active': true,
    'title': 'Павелецкая',
    'line': 2,
    'id': 28
  },
  {
    'active': true,
    'title': 'Павелецкая',
    'line': 5,
    'id': 77
  },
  {
    'active': true,
    'title': 'Панфиловская',
    'line': 17,
    'id': 305
  },
  {
    'active': true,
    'title': 'Парк Победы',
    'line': 3,
    'id': 52
  },
  {
    'active': true,
    'title': 'Парк Победы',
    'line': 14,
    'id': 218
  },
  {
    'active': true,
    'title': 'Парк культуры',
    'line': 1,
    'id': 13
  },
  {
    'active': true,
    'title': 'Парк культуры',
    'line': 5,
    'id': 74
  },
  {
    'active': true,
    'title': 'Партизанская',
    'line': 3,
    'id': 43
  },
  {
    'active': true,
    'title': 'Первомайская',
    'line': 3,
    'id': 41
  },
  {
    'active': true,
    'title': 'Перово',
    'line': 8,
    'id': 131
  },
  {
    'active': true,
    'title': 'Петровский парк',
    'line': 16,
    'id': 298
  },
  {
    'active': true,
    'title': 'Петровско-Разумовская',
    'line': 9,
    'id': 141
  },
  {
    'active': true,
    'title': 'Петровско-Разумовская',
    'line': 10,
    'id': 209
  },
  {
    'active': true,
    'title': 'Печатники',
    'line': 10,
    'id': 171
  },
  {
    'active': false,
    'title': 'Печатники',
    'line': 16,
    'id': 254
  },
  {
    'active': true,
    'title': 'Пионерская',
    'line': 4,
    'id': 62
  },
  {
    'active': true,
    'title': 'Планерная',
    'line': 7,
    'id': 110
  },
  {
    'active': true,
    'title': 'Площадь Гагарина',
    'line': 17,
    'id': 288
  },
  {
    'active': true,
    'title': 'Площадь Ильича',
    'line': 8,
    'id': 134
  },
  {
    'active': true,
    'title': 'Площадь Революции',
    'line': 3,
    'id': 48
  },
  {
    'active': false,
    'title': 'Плющиха',
    'line': 14,
    'id': 221
  },
  {
    'active': true,
    'title': 'Полежаевская',
    'line': 7,
    'id': 115
  },
  {
    'active': true,
    'title': 'Полянка',
    'line': 9,
    'id': 149
  },
  {
    'active': true,
    'title': 'Пражская',
    'line': 9,
    'id': 158
  },
  {
    'active': true,
    'title': 'Преображенская площадь',
    'line': 1,
    'id': 3
  },
  {
    'active': true,
    'title': 'Прокшино',
    'line': 1,
    'id': 309
  },
  {
    'active': true,
    'title': 'Пролетарская',
    'line': 7,
    'id': 123
  },
  {
    'active': true,
    'title': 'Проспект Вернадского',
    'line': 1,
    'id': 18
  },
  {
    'active': false,
    'title': 'Проспект Вернадского',
    'line': 16,
    'id': 247
  },
  {
    'active': true,
    'title': 'Проспект Мира',
    'line': 5,
    'id': 81
  },
  {
    'active': true,
    'title': 'Проспект Мира',
    'line': 6,
    'id': 93
  },
  {
    'active': true,
    'title': 'Профсоюзная',
    'line': 6,
    'id': 102
  },
  {
    'active': true,
    'title': 'Пушкинская',
    'line': 7,
    'id': 119
  },
  {
    'active': true,
    'title': 'Пятницкое шоссе',
    'line': 3,
    'id': 200
  },
  {
    'active': true,
    'title': 'Раменки',
    'line': 14,
    'id': 225
  },
  {
    'active': true,
    'title': 'Рассказовка',
    'line': 14,
    'id': 269
  },
  {
    'active': true,
    'title': 'Речной вокзал',
    'line': 2,
    'id': 39
  },
  {
    'active': false,
    'title': 'Ржевская',
    'line': 16,
    'id': 261
  },
  {
    'active': true,
    'title': 'Рижская',
    'line': 6,
    'id': 92
  },
  {
    'active': true,
    'title': 'Римская',
    'line': 10,
    'id': 167
  },
  {
    'active': true,
    'title': 'Ростокино',
    'line': 17,
    'id': 276
  },
  {
    'active': true,
    'title': 'Румянцево',
    'line': 1,
    'id': 194
  },
  {
    'active': true,
    'title': 'Рязанский проспект',
    'line': 7,
    'id': 127
  },
  {
    'active': true,
    'title': 'Савеловская',
    'line': 16,
    'id': 307
  },
  {
    'active': true,
    'title': 'Савёловская',
    'line': 9,
    'id': 144
  },
  {
    'active': true,
    'title': 'Саларьево',
    'line': 1,
    'id': 195
  },
  {
    'active': true,
    'title': 'Свиблово',
    'line': 6,
    'id': 88
  },
  {
    'active': true,
    'title': 'Севастопольская',
    'line': 9,
    'id': 155
  },
  {
    'active': false,
    'title': 'Севастопольский проспект',
    'line': 16,
    'id': 250
  },
  {
    'active': true,
    'title': 'Селигерская',
    'line': 10,
    'id': 212
  },
  {
    'active': true,
    'title': 'Семёновская',
    'line': 3,
    'id': 44
  },
  {
    'active': true,
    'title': 'Серпуховская',
    'line': 9,
    'id': 150
  },
  {
    'active': true,
    'title': 'Славянский бульвар',
    'line': 3,
    'id': 53
  },
  {
    'active': true,
    'title': 'Смоленская',
    'line': 3,
    'id': 50
  },
  {
    'active': true,
    'title': 'Смоленская',
    'line': 4,
    'id': 69
  },
  {
    'active': true,
    'title': 'Сокол',
    'line': 2,
    'id': 36
  },
  {
    'active': true,
    'title': 'Соколиная Гора',
    'line': 17,
    'id': 296
  },
  {
    'active': true,
    'title': 'Сокольники',
    'line': 1,
    'id': 4
  },
  {
    'active': false,
    'title': 'Сокольники',
    'line': 16,
    'id': 260
  },
  {
    'active': true,
    'title': 'Солнцево',
    'line': 14,
    'id': 266
  },
  {
    'active': true,
    'title': 'Спартак',
    'line': 7,
    'id': 203
  },
  {
    'active': true,
    'title': 'Спортивная',
    'line': 1,
    'id': 15
  },
  {
    'active': true,
    'title': 'Сретенский бульвар',
    'line': 10,
    'id': 165
  },
  {
    'active': false,
    'title': 'Стахановская',
    'line': 15,
    'id': 232
  },
  {
    'active': true,
    'title': 'Стрешнево',
    'line': 17,
    'id': 282
  },
  {
    'active': true,
    'title': 'Строгино',
    'line': 3,
    'id': 57
  },
  {
    'active': true,
    'title': 'Студенческая',
    'line': 4,
    'id': 67
  },
  {
    'active': false,
    'title': 'Суворовская',
    'line': 5,
    'id': 201
  },
  {
    'active': true,
    'title': 'Сухаревская',
    'line': 6,
    'id': 94
  },
  {
    'active': true,
    'title': 'Сходненская',
    'line': 7,
    'id': 111
  },
  {
    'active': true,
    'title': 'Таганская',
    'line': 5,
    'id': 78
  },
  {
    'active': true,
    'title': 'Таганская',
    'line': 7,
    'id': 122
  },
  {
    'active': true,
    'title': 'Тверская',
    'line': 2,
    'id': 31
  },
  {
    'active': true,
    'title': 'Театральная',
    'line': 2,
    'id': 30
  },
  {
    'active': true,
    'title': 'Текстильщики',
    'line': 7,
    'id': 125
  },
  {
    'active': false,
    'title': 'Текстильщики',
    'line': 16,
    'id': 255
  },
  {
    'active': true,
    'title': 'Телецентр',
    'line': 13,
    'id': 190
  },
  {
    'active': false,
    'title': 'Терехово',
    'line': 16,
    'id': 243
  },
  {
    'active': false,
    'title': 'Терешково',
    'line': 14,
    'id': 265
  },
  {
    'active': true,
    'title': 'Технопарк',
    'line': 2,
    'id': 197
  },
  {
    'active': true,
    'title': 'Тимирязевская',
    'line': 9,
    'id': 142
  },
  {
    'active': true,
    'title': 'Тимирязевская',
    'line': 13,
    'id': 192
  },
  {
    'active': true,
    'title': 'Третьяковская',
    'line': 6,
    'id': 97
  },
  {
    'active': true,
    'title': 'Третьяковская',
    'line': 8,
    'id': 136
  },
  {
    'active': false,
    'title': 'Третьяковская',
    'line': 14,
    'id': 222
  },
  {
    'active': true,
    'title': 'Тропарёво',
    'line': 1,
    'id': 193
  },
  {
    'active': true,
    'title': 'Трубная',
    'line': 10,
    'id': 164
  },
  {
    'active': true,
    'title': 'Тульская',
    'line': 9,
    'id': 151
  },
  {
    'active': true,
    'title': 'Тургеневская',
    'line': 6,
    'id': 95
  },
  {
    'active': true,
    'title': 'Тушинская',
    'line': 7,
    'id': 112
  },
  {
    'active': true,
    'title': 'Тёплый стан',
    'line': 6,
    'id': 107
  },
  {
    'active': true,
    'title': 'Угрешская',
    'line': 17,
    'id': 293
  },
  {
    'active': true,
    'title': 'Улица 1905 года',
    'line': 7,
    'id': 117
  },
  {
    'active': true,
    'title': 'Улица Горчакова',
    'line': 12,
    'id': 185
  },
  {
    'active': true,
    'title': 'Улица Дмитриевского',
    'line': 15,
    'id': 227
  },
  {
    'active': true,
    'title': 'Улица Милашенкова',
    'line': 13,
    'id': 191
  },
  {
    'active': false,
    'title': 'Улица Народного ополчения',
    'line': 16,
    'id': 241
  },
  {
    'active': false,
    'title': 'Улица Новаторов',
    'line': 16,
    'id': 248
  },
  {
    'active': true,
    'title': 'Улица Сергея Эйзенштейна',
    'line': 13,
    'id': 187
  },
  {
    'active': true,
    'title': 'Улица Скобелевская',
    'line': 12,
    'id': 183
  },
  {
    'active': true,
    'title': 'Улица Старокачаловская',
    'line': 12,
    'id': 182
  },
  {
    'active': true,
    'title': 'Улица академика Королёва',
    'line': 13,
    'id': 189
  },
  {
    'active': true,
    'title': 'Улица академика Янгеля',
    'line': 9,
    'id': 159
  },
  {
    'active': true,
    'title': 'Университет',
    'line': 1,
    'id': 17
  },
  {
    'active': true,
    'title': 'Филатов луг',
    'line': 1,
    'id': 308
  },
  {
    'active': true,
    'title': 'Фили',
    'line': 4,
    'id': 65
  },
  {
    'active': true,
    'title': 'Филёвский парк',
    'line': 4,
    'id': 63
  },
  {
    'active': true,
    'title': 'Фонвизинская',
    'line': 10,
    'id': 208
  },
  {
    'active': true,
    'title': 'Фрунзенская',
    'line': 1,
    'id': 14
  },
  {
    'active': true,
    'title': 'Ховрино',
    'line': 2,
    'id': 199
  },
  {
    'active': false,
    'title': 'Ходынское поле',
    'line': 16,
    'id': 237
  },
  {
    'active': true,
    'title': 'Хорошёво',
    'line': 17,
    'id': 283
  },
  {
    'active': true,
    'title': 'Хорошёвская',
    'line': 16,
    'id': 238
  },
  {
    'active': true,
    'title': 'ЦСКА',
    'line': 16,
    'id': 299
  },
  {
    'active': true,
    'title': 'Царицыно',
    'line': 2,
    'id': 23
  },
  {
    'active': true,
    'title': 'Цветной бульвар',
    'line': 9,
    'id': 146
  },
  {
    'active': false,
    'title': 'Челобитьево',
    'line': 6,
    'id': 202
  },
  {
    'active': true,
    'title': 'Черкизовская',
    'line': 1,
    'id': 2
  },
  {
    'active': true,
    'title': 'Чертановская',
    'line': 9,
    'id': 156
  },
  {
    'active': true,
    'title': 'Чеховская',
    'line': 9,
    'id': 147
  },
  {
    'active': true,
    'title': 'Чистые пруды',
    'line': 1,
    'id': 8
  },
  {
    'active': true,
    'title': 'Чкаловская',
    'line': 10,
    'id': 166
  },
  {
    'active': true,
    'title': 'Шаболовская',
    'line': 6,
    'id': 99
  },
  {
    'active': true,
    'title': 'Шелепиха',
    'line': 16,
    'id': 300
  },
  {
    'active': true,
    'title': 'Шелепиха',
    'line': 17,
    'id': 284
  },
  {
    'active': false,
    'title': 'Шереметьевская',
    'line': 16,
    'id': 262
  },
  {
    'active': true,
    'title': 'Шипиловская',
    'line': 10,
    'id': 177
  },
  {
    'active': true,
    'title': 'Шоссе Энтузиастов',
    'line': 8,
    'id': 132
  },
  {
    'active': true,
    'title': 'Шоссе Энтузиастов',
    'line': 17,
    'id': 271
  },
  {
    'active': true,
    'title': 'Щукинская',
    'line': 7,
    'id': 113
  },
  {
    'active': true,
    'title': 'Щёлковская',
    'line': 3,
    'id': 40
  },
  {
    'active': true,
    'title': 'Электрозаводская',
    'line': 3,
    'id': 45
  },
  {
    'active': false,
    'title': 'Электрозаводская',
    'line': 16,
    'id': 259
  },
  {
    'active': false,
    'title': 'Юго-Восточная',
    'line': 15,
    'id': 234
  },
  {
    'active': true,
    'title': 'Юго-Западная',
    'line': 1,
    'id': 19
  },
  {
    'active': true,
    'title': 'Южная',
    'line': 9,
    'id': 157
  },
  {
    'active': true,
    'title': 'Ясенево',
    'line': 6,
    'id': 108
  }
];
