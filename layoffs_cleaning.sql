-- ================================================= --
-- Data cleaning project :layoffs dataset (MY SQL)
-- الفكرة من سلسلة Alex THE Analystوالتنفيذ والشرح مني 
-- =================================================--

-- المرحلة الاولى
-- قمنا بانشاء جدول وسنقوم بادراج بياناتنا الخام بداخله لكى نحافظ على نسخة من بياناتنا الخام
create table layoffs_staging 
like layoffs;
-- تحذير: يشتغل مرة وحدة 
insert into layoffs_staging select * from layoffs;

-- المرحلة الثانية
-- 1.2معاينة التكرارات
-- row_number بيرقّم الصفوف المتطابقة: الأول 1 والمكرر 2 وأكتر
-- يعني row_num > 1 معناها صف مكرر
with duplicate_cte as (
  select *,
  row_number() over(
    partition by company, location, industry, total_laid_off,
    percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) as row_num
  from layoffs_staging
)
select * from duplicate_cte where row_num > 1;

-- 2.2 ننشئ جدول جديد فيه عمود row_num، لأن MySQL ما بيسمح نحذف من CTE
create table layoffs_staging2 like layoffs_staging;
alter table layoffs_staging2 add column row_num int;

-- تحذير: يشتغل مرة وحدة 
insert into layoffs_staging2
select *, row_number() over(
  partition by company, location, industry, total_laid_off,
  percentage_laid_off, `date`, stage, country, funds_raised_millions
) from layoffs_staging;
-- نحذف من الجدول الجديد الصفوف المكررة (row_num > 1)
delete from layoffs_staging2 where row_num > 1;
-- فحص النتيجة لازم (0 صف)
select *
from layoffs_staging2
where row_num > 1;

-- المرحلة الثالثة: توحيد البيانات

-- 3.1 شيل المسافات الزايدة من أسماء الشركات
select company ,trim(company) 
from layoffs_staging2;
-- حدثت الجدول وحفظت البيانات الجديدة بعد تطبيق دالة trimعلى عامود company
update layoffs_staging2
set company= trim(company);

-- 3.2 توحيد اسم الصناعة (crypto بأكتر من شكل)
-- بحثت عن كل شي cryptoموجودة في عامود الصناعة
select *
from layoffs_staging2
where industry like'crypto%';

-- قمنا بتعديل (اذا كانت تشبه cryptoسوف تصبح crypto)
update layoffs_staging2
set industry ='crypto'
where industry like 'crypto%';

-- 3.3 توحيد اسم البلد (النقطة بآخر United States.)
-- نبحث في عامود country نجد كلمة تنتهي بنقطة
select distinct country
from layoffs_staging2
order by 1;

-- ازالة النقطة في نهاية كل شي موجود في عامودcountry
select distinct country,trim(trailing'.'from country)
from layoffs_staging2
order by 1; 

update layoffs_staging2
set country =trim(trailing'.'from country)
where country like'United States%';

-- 3.4 تحويل التاريخ من نص لـ DATE
select `date`
from layoffs_staging2;

-- انتبه لحجم الحرف %Y اربع خانات للسنة(2022)
-- تغير نوع عامود data من نص الى data
-- تحذير يشغل مرة واحدة لو انعاد بتتحول التواريخ
update layoffs_staging2
set `data` = str_to_date(`date`, '%m/%d/%Y');

-- تعديل ع عامود  من من الجدول
alter table layoffs_staging2
modify column `date` date;

-- نتاكد ان نوعdate صار data
describe layoffs_staging2;

-- ما في null مفاجى
select `date`
from layoffs_staging2
order by 1;

-- المرحلة الرابعة: القيم الفاضية و NULL

-- 4.1 نبحث عن الصفوف التى الصناعة فيها null او فاضية
select *
from layoffs_staging2
where industry is null or industry = '';

-- نقوم بتحويل الفارغة الى قيم خالية (لانهم مختلفين في MySQL)
-- تحذير: بغيّر الجدول، شغّله مرة وحدة
update layoffs_staging2
set industry = null
where industry = '';

-- 4.3 رح يظهر عندي عامودين واحد للقيم الفارغة وواحد للقيم الخالية
select t1.company, t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
  on t1.company = t2.company
where t1.industry is null
  and t2.industry is not null;

-- 4.4 رح اعبي كل صف فاضي من الصف الى في قيمة
-- تحذير يشغل مرة واحدة
update layoffs_staging2 t1
join layoffs_staging2 t2
  on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
  and t2.industry is not null;

-- 4.5 طبيعي يضل عندي صفوف فيها قيم فارغة لاني ما لها صف ثاني بالصناعة
select *
from layoffs_staging2
where industry is null or industry = '';

-- المرحلة الخامسة: حذف الصفوف والأعمدة غير الضرورية

-- 5.1 بدي شوف شوفي فارغ بالعامودين total_laid_offوالعامود percentage_laid_offمعا
select *
from layoffs_staging2
where total_laid_off is null
  and (percentage_laid_off is null
       or trim(percentage_laid_off) in ('', 'NULL'));
  
  
-- 5.2 ال delete بيشتفل ع null فقط لكن احيانا يكون لدي قيم نص وليس null نلاحظ او ال delete ياثر ع صفر صف
-- نقوم بحذف هذه الفارغات الموجودة في العامود معا
-- نتاكد اول شي من select لانو الحذف مافي رجعة
delete
from layoffs_staging2
where total_laid_off is null
  and (percentage_laid_off is null
       or trim(percentage_laid_off) in ('', 'NULL'));

-- 5.3 اقوم بحذف عامود row_num خلص دورو بعد حذف التكرارات
alter table layoffs_staging2
drop column row_num;

-- 5.4 فحص نهائي
select count(*) from layoffs_staging2;
-- النتيجة النهاىية 1995 صف
-- التفاصيل والمشاكل الي واجهتها بملف README.md
















































