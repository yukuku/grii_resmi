import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _TitleText extends StatelessWidget {
  final String text;

  _TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0)),
        SizedBox(height: 32),
      ],
    );
  }
}

class _HeadingText extends Text {
  _HeadingText(String text) : super(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0));
}

class _BodyText extends StatelessWidget {
  final String text;

  _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 14, height: 1.25));
  }
}

class _BulletText extends StatelessWidget {
  final String text;

  const _BulletText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 16, height: 16, child: Center(child: FaIcon(FontAwesomeIcons.circle, size: 4))),
        Expanded(child: Text(text)),
      ],
    );
  }
}

final pengakuanIman = [
  _TitleText('Pengakuan Iman REFORMED INJILI'),
  _HeadingText('ALLAH'),
  _BodyText(
      'Kami percaya kepada satu-satunya Allah yang hidup dan benar, yang kekal dan keberadaan-Nya tergantung pada dirinya sendiri, yang melampaui dan mendahului semua ciptaan; yang dalam kekekalan-Nya ada dalam tiga pribadi; Bapa, Putera dan Roh Kudus, yaitu Allah yang Esa; yang menciptakan alam semesta dari ketiadaan oleh Firman-Nya yang berkuasa; yang menopang dan memerintah segala sesuatu yang telah diciptakan-Nya serta memelihara ketetapan-ketetapan-Nya yang kekal.'),
  _HeadingText('ALKITAB'),
  _BodyText(
      'Kami percaya bahwa Alkitab Perjanjian Lama dan Perjanjian Baru adalah penyataan Allah yang sempurna yang diilhamkan Roh Kudus kepada para penulisnya dan karena itu adalah benar tanpa salah dalam naskah aslinya. Alkitab menyatakan di dalamnya kesaksian Roh Kudus, dan merupakan wibawa tunggal dan mutlak bagi iman dan kehidupan, baik untuk perseorangan, gereja, maupun masyarakat. Kami percaya bahwa Alkitab tidak bersalah dalam segala hal yang diajarkannya, termasuk hal-hal yang menyangkut sejarah dan ilmu.'),
  _HeadingText('MANUSIA'),
  _BodyText(
      'Kami percaya bahwa manusia telah diciptakan secara unik menurut rupa Allah, diciptakan dengan kekudusan, keadilan dan pengenalan sejati; dan diperintahkan Allah untuk menghayati pikiran-pikiran Allah sebagai seorang pemelihara perjanjian yang taat: ia dipercayakan untuk memerintah dan mengusahakan ciptaan Allah lainnya untuk kemuliaan Allah. Kami percaya bahwa seluruh segi kehidupan harus dihayati di bawah perintah Allah sebagai ungkapan ketaatan kepada hukum-hukum Allah.'),
  _HeadingText('DOSA'),
  _BodyText(
      'Kami percaya bahwa apa yang telah terjadi dalam diri Adam dan juga adalah wakil umat manusia, mengakibatkan seluruh umat manusia telah jatuh dalam dosa dan maut; mati secara rohani, patut menerima murka adil Allah, tanpa pengharapan dan tanpa pertolongan untuk memperoleh keselamatan, baik dari dirinya sendiri atau dari luar dirinya maupun dari dunia ini.'),
  _HeadingText('PERJANJIAN ANUGERAH'),
  _BodyText(
      'Kami percaya bahwa Allah dalam kekekalan telah membuat perjanjian untuk umat pilihan-Nya, dengan Yesus Kristus sebagai Kepala; bahwa melalui ketaatan Yesus Kristus yang sempurna dan kematian-Nya sebagai pengganti manusia di kayu salib, Kristus telah memenuhi tuntutan murka Allah terhadap umat-Nya. Melalui kuasa kebangkitan Kristus, Allah terus-menerus memanggil dan mengumpulkan umat-Nya dari segala zaman dan segala bangsa untuk menjadi suatu imamat yang rajani dan bangsa yang kudus bagi kemuliaan-Nya.'),
  _HeadingText('YESUS KRISTUS'),
  _BodyText(
      'Kami percaya kepada Yesus Kristus, Pribadi kedua Allah Tritunggal, Allah sejati dan manusia sejati, satu-satunya Juruselamat manusia; yang telah dikandung oleh Roh Kudus, lahir dari anak dara Maria; hidup tanpa dosa, disalibkan mati dan bangkit dari kematian, naik ke surga, duduk di sebelah kanan Allah Bapa untuk bersyafaat bagi umat-Nya sebagai Imam Besar, yang berhasil dan penuh pengertian; bahwa Dia akan datang kembali dalam tubuh kemuliaan-Nya, secara kasatmata dan secara tiba-tiba untuk menghakimi orang yang hidup dan yang mati.'),
  _HeadingText('ROH KUDUS'),
  _BodyText(
      'Kami percaya kepada Roh Kudus, Pribadi ketiga Allah Tritunggal, Pengilham Ilahi Alkitab, yang menginsyafkan manusia akan dosa mereka melalui Firman-Nya, yang melahirbarukan mereka, sehingga tumbuh iman dan pertobatan kepada Yesus Kristus untuk keselamatan; Dia memperlengkapi orang-orang beriman dengan kuasa untuk menaati hukum-hukum Allah; Dia mengaruniakan kepada Gereja Yesus Kristus karunia-karunia untuk pelayanan orang kudus; Dia bersyafaat bagi orang beriman dengan keluh kesah yang tak terucapkan untuk dan sampai hari pemuliaan umat Allah.'),
  _HeadingText('GEREJA DAN MISI'),
  _BodyText(
      'Kami percaya akan satu Gereja yang kudus dan am, yang terdiri dari seluruh umat pilihan Allah dari segala zaman dan yang sebagiannya kini terhisap dalam gereja setempat; gereja '
      'setempat harus merupakan ungkapan dari sifat Gereja yang kudus dan am tersebut dengan menjaga kemurnian ajaran sesuai dengan Alkitab, dengan mendahulukan persatuan berdasarkan kebenaran di dalam ikatan kasih antara berbagai gereja setempat dan aliran gereja yang ada, dengan memancarkan kemuliaan Allah melalui ibadah, pengajaran Firman Allah, '
      'pelaksanaan baptisan dan perjamuan kudus, persekutuan, pelaksanaan disiplin dalam kasih, pelayanan dan misi, kami percaya bahwa gereja ada di dalam dunia untuk memberitakan Injil Yesus Kristus dan mengungkapkan Ketuhanan Kristus lewat perbuatan-perbuatan nyata. Gereja menjalankan misi Yesus Kristus, yaitu menegakkan pemerintahan Kerajaan Allah atas dunia ini, baik melalui usaha-usaha penginjilan di dunia ini, sampai Kristus datang kembali untuk merampungkan penggenapan Kerajaan-Nya.'),
];

final pengakuanPenginjilan = [
  _TitleText('Pengakuan Iman PENGINJILAN'),
  _BodyText('Aku percaya Injil sebagai kuasa Allah untuk menyelamatkan setiap orang yang percaya.'),
  _BodyText(
      'Aku percaya satu Allah di dalam Tiga Pribadi, Pencipta manusia dan dunia, Hakim Tertinggi atas semua dosa dan Sumber keselamatan manusia.'),
  _BodyText(
      'Aku percaya kejatuhan manusia sebagai fakta sejarah yang menyebabkan polusi natur manusia secara total. Oleh sebab itu, manusia tidak mampu menyelamatkan dirinya sendiri.'),
  _BodyText(
      'Aku percaya anugerah Allah yang berdaulat kepada manusia yang tidak layak menerima keselamatan, yang memilih umat-Nya di dalam hikmat-Nya yang tertinggi oleh penetapan-Nya yang kekal, dan bertindak di dalam proses dinamis sejarah, untuk menebus mereka di dalam Anak Tunggal-Nya, Yesus Kristus.'),
  _BodyText(
      'Aku percaya akan inkarnasi Yesus Kristus melalui kelahiran anak dara, hidup-Nya tanpa dosa, penyaliban, kematian, kebangkitan dan kenaikan-Nya adalah fakta-fakta sejarah yang menyusun esensi dan berita Injil, sebagai satu-satunya sarana untuk mencapai keselamatan Allah.'),
  _BodyText(
      'Aku percaya kuasa darah Yesus Kristus yang membersihkan, terkandung di dalam pengorbanan-Nya yang bersifat penggantian, pemulihan (propisiasi), penebusan dan pendamaian, yang memberikan hidup baru kepada manusia.'),
  _BodyText(
      'Aku percaya akan pemberitaan Injil sebagai satu-satunya berita baik, yang memberikan dasar hidup bahagia dan pengharapan kekal bagi umat manusia. Penginjilan adalah:'),
  _BulletText('Kesaksian hidup orang-orang Kristen sejati yang menundukkan diri mereka kepada perintah Allah.'),
  _BulletText(
      'Menciptakan pertemuan pribadi antara orang-orang berdosa dengan Allah, melalui perantaraan Yesus Kristus.'),
  _BulletText('Penyebab yang menimbulkan iman yang menyelamatkan di dalam hati manusia.'),
  _BulletText('Kunci menuju pertumbuhan gereja dan kesukaan akan kehadiran-Nya yang kekal.'),
  _BodyText(
      'Aku percaya pertobatan sebagai bukti kelahiran baru dari Roh Kudus yang menghasilkan iman sejati di dalam Yesus Kristus dan menghasilkan buah-buah hidup baru.'),
  _BodyText(
      'Aku percaya akan pengurapan Roh Kudus di dalam penginjilan dalam bentuk keberanian, hikmat, kuat-kuasa, dan kesukaan menjadi saksi atas mereka yang mentaati Amanat Agung Yesus Kristus.'),
  _BodyText(
      'Aku percaya akan finalitas Injil yang adalah sempurna pada dirinya, yang tidak dapat digantikan atau dibandingkan, baik dengan pemikiran agama, ide filsafat, dan perbuatan baik duniawi (beda secara kualitatif), maupun dengan mandat kebudayaan dan kepedulian sosial di dalam iman ortodoks dan injili (hanya merupakan pelengkap dari pra- dan pasca-penginjilan), ataupun kariuna Roh Kudus dan mujizat dan tanda-tanda di dalam Alkitab (yang kadang-kadang Allah gunakan untuk menyaksikan Injil-Nya). Kita harus mempertahankan kesempurnaan Injil.'),
  _BodyText(
      'Aku percaya kuasa yang tidak berubah dari Injil Yesus Kristus yang mampu memelihara umat tebusan-Nya serta mengubah masyarakat melalui kesaksian mereka hingga hari penggenapan pemuliaan di saat kedatangan Yesus kembali.'),
];
