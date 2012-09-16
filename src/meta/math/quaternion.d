/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    meta, a render framework
    Copyright (C) 2012 Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com> 

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

module meta.math.quaternion;

/* imports */
private {
    import std.algorithm : reduce;
    import std.math : sin, sqrt;
    import meta.math.axis;
}
public {
}

struct SQuat {
    alias typeof(this) that;

    private SAxis3 _axis;
    private float _phi;

    @property {
        that init() {
            return that(SAxis3(), 1.0f);
        }

        float x() {
            return _axis.x;
        }
        float y() {
            return _axis.y;
        }

        float z() {
            return _axis.z;
        }

        float w() {
            return _phi;
        }
    }

    this(SAxis3 a, float phi) in {
        assert ( a.norm == 1.0f ); /* the axis has to be normalized */
    } body {
        _axis = a * sin(phi/2);
        _phi = phi;
    }

    void normalize() {
        //auto al = _axis.reduce!("a + b*b");
        auto al = _axis.x*_axis.x + _axis.y*_axis.y + _axis.z*_axis.z;
        auto l = sqrt(al + _phi*_phi);
        assert ( l != 0.0f );
        _axis /= l;
        _phi /= l;
    }

    ref that opOpAssign(string op)(ref const that rhs) if (op == "*") {
        _axis = SAxis3(
            _phi*rhs._axis.x + _axis.x*rhs._phi + _axis.y*rhs._axis.z - _axis.z*rhs._axis.y,
            _phi*rhs._axis.y + _axis.y*rhs._phi + _axis.z*rhs._axis.x - _axis.x*rhs._axis.z,
            _phi*rhs._axis.z + _axis.z*rhs._phi + _axis.x*rhs._axis.y - _axis.y*rhs._axis.x
        );
        _phi = _phi*rhs._phi - _axis.x*rhs._axis.x - _axis.y*rhs._axis.y - _axis.z*rhs._axis.z;
        normalize();
        return this;
    }
    
    that opBinary(string op)(ref const that lhs, ref const that rhs) if (op == "*") {
        lhs *= rhs;
        return lhs;
    }

    /* cast to matrix */
    auto opCast(SMat44)() {
        SMat44 r = void;

        foreach (i; 0..3) {
            r[i,3] = r[3,i] = 0.0f;
        }

        r[0,0] = 1.0f - 2*_axis.y*_axis.y - 2*_axis.z*_axis.z;
        r[0,1] = 2*_axis.x*_axis.y - 2*_phi*_axis.z;
        r[0,2] = 2*_axis.x*_axis.z + 2*_phi*_axis.y;

        r[1,0] = 2*_axis.x*_axis.y + 2*_phi*_axis.z;
        r[1,1] = 1.0f - 2*_axis.x*_axis.x - 2*_axis.z*_axis.z;
        r[1,2] = 2*_axis.y*_axis.z - 2*_phi*_axis.x;

        r[2,0] = 2*_axis.x*_axis.z - 2*_phi*_axis.y;
        r[2,1] = 2*_axis.y*_axis.z + 2*_phi*_axis.x;
        r[2,2] = 1.0f - 2*_axis.x*_axis.x - 2*_axis.y*_axis.y;
        r[3,3] = 1.0f;

        return r;
    }
}
