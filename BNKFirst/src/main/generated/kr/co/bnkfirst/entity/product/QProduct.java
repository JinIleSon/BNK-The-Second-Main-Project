package kr.co.bnkfirst.entity.product;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QProduct is a Querydsl query type for Product
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProduct extends EntityPathBase<Product> {

    private static final long serialVersionUID = 1770054983L;

    public static final QProduct product = new QProduct("product");

    public final NumberPath<Integer> id = createNumber("id", Integer.class);

    public final NumberPath<Float> pbirate = createNumber("pbirate", Float.class);

    public final StringPath pcond = createString("pcond");

    public final StringPath pcprd = createString("pcprd");

    public final StringPath pdirate = createString("pdirate");

    public final StringPath pelgbl = createString("pelgbl");

    public final NumberPath<Float> phirate = createNumber("phirate", Float.class);

    public final StringPath pid = createString("pid");

    public final StringPath pinfo = createString("pinfo");

    public final StringPath pirinfo = createString("pirinfo");

    public final StringPath pjnfee = createString("pjnfee");

    public final StringPath pname = createString("pname");

    public final StringPath pprfcrt = createString("pprfcrt");

    public final StringPath prmthd = createString("prmthd");

    public final StringPath psubtitle = createString("psubtitle");

    public final StringPath pterms = createString("pterms");

    public final StringPath ptype = createString("ptype");

    public final DateTimePath<java.time.LocalDateTime> pupdate = createDateTime("pupdate", java.time.LocalDateTime.class);

    public final StringPath pwtpi = createString("pwtpi");

    public QProduct(String variable) {
        super(Product.class, forVariable(variable));
    }

    public QProduct(Path<? extends Product> path) {
        super(path.getType(), path.getMetadata());
    }

    public QProduct(PathMetadata metadata) {
        super(Product.class, metadata);
    }

}

